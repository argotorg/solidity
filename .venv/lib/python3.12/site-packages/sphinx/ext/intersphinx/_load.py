"""This module contains the code for loading intersphinx inventories."""

from __future__ import annotations

import concurrent.futures
import functools
import posixpath
import time
from os import path
from typing import TYPE_CHECKING
from urllib.parse import urlsplit, urlunsplit

from sphinx.builders.html import INVENTORY_FILENAME
from sphinx.ext.intersphinx._shared import LOGGER, InventoryAdapter
from sphinx.locale import __
from sphinx.util import requests
from sphinx.util.inventory import InventoryFile

if TYPE_CHECKING:
    from typing import IO

    from sphinx.application import Sphinx
    from sphinx.config import Config
    from sphinx.ext.intersphinx._shared import InventoryCacheEntry
    from sphinx.util.typing import Inventory


def normalize_intersphinx_mapping(app: Sphinx, config: Config) -> None:
    for key, value in config.intersphinx_mapping.copy().items():
        try:
            if isinstance(value, (list, tuple)):
                # new format
                name, (uri, inv) = key, value
                if not isinstance(name, str):
                    LOGGER.warning(__('intersphinx identifier %r is not string. Ignored'),
                                   name)
                    config.intersphinx_mapping.pop(key)
                    continue
            else:
                # old format, no name
                # xref RemovedInSphinx80Warning
                name, uri, inv = None, key, value
                msg = (
                    "The pre-Sphinx 1.0 'intersphinx_mapping' format is "
                    'deprecated and will be removed in Sphinx 8. Update to the '
                    'current format as described in the documentation. '
                    f"Hint: `intersphinx_mapping = {{'<name>': {(uri, inv)!r}}}`."
                    'https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html#confval-intersphinx_mapping'  # NoQA: E501
                )
                LOGGER.warning(msg)

            if not isinstance(inv, tuple):
                config.intersphinx_mapping[key] = (name, (uri, (inv,)))
            else:
                config.intersphinx_mapping[key] = (name, (uri, inv))
        except Exception as exc:
            LOGGER.warning(__('Failed to read intersphinx_mapping[%s], ignored: %r'), key, exc)
            config.intersphinx_mapping.pop(key)


def load_mappings(app: Sphinx) -> None:
    """Load all intersphinx mappings into the environment."""
    now = int(time.time())
    inventories = InventoryAdapter(app.builder.env)
    intersphinx_cache: dict[str, InventoryCacheEntry] = inventories.cache

    with concurrent.futures.ThreadPoolExecutor() as pool:
        futures = []
        name: str | None
        uri: str
        invs: tuple[str | None, ...]
        for name, (uri, invs) in app.config.intersphinx_mapping.values():
            futures.append(pool.submit(
                fetch_inventory_group, name, uri, invs, intersphinx_cache, app, now,
            ))
        updated = [f.result() for f in concurrent.futures.as_completed(futures)]

    if any(updated):
        inventories.clear()

        # Duplicate values in different inventories will shadow each
        # other; which one will override which can vary between builds
        # since they are specified using an unordered dict.  To make
        # it more consistent, we sort the named inventories and then
        # add the unnamed inventories last.  This means that the
        # unnamed inventories will shadow the named ones but the named
        # ones can still be accessed when the name is specified.
        named_vals = []
        unnamed_vals = []
        for name, _expiry, invdata in intersphinx_cache.values():
            if name:
                named_vals.append((name, invdata))
            else:
                unnamed_vals.append((name, invdata))
        for name, invdata in sorted(named_vals) + unnamed_vals:
            if name:
                inventories.named_inventory[name] = invdata
            for type, objects in invdata.items():
                inventories.main_inventory.setdefault(type, {}).update(objects)


def fetch_inventory_group(
    name: str | None,
    uri: str,
    invs: tuple[str | None, ...],
    cache: dict[str, InventoryCacheEntry],
    app: Sphinx,
    now: int,
) -> bool:
    cache_time = now - app.config.intersphinx_cache_limit * 86400
    failures = []
    try:
        for inv in invs:
            if not inv:
                inv = posixpath.join(uri, INVENTORY_FILENAME)
            # decide whether the inventory must be read: always read local
            # files; remote ones only if the cache time is expired
            if '://' not in inv or uri not in cache or cache[uri][1] < cache_time:
                safe_inv_url = _get_safe_url(inv)
                inv_descriptor = name or 'main_inventory'
                LOGGER.info(__("loading intersphinx inventory '%s' from %s..."),
                            inv_descriptor, safe_inv_url)
                try:
                    invdata = fetch_inventory(app, uri, inv)
                except Exception as err:
                    failures.append(err.args)
                    continue
                if invdata:
                    cache[uri] = name, now, invdata
                    return True
        return False
    finally:
        if failures == []:
            pass
        elif len(failures) < len(invs):
            LOGGER.info(__('encountered some issues with some of the inventories,'
                           ' but they had working alternatives:'))
            for fail in failures:
                LOGGER.info(*fail)
        else:
            issues = '\n'.join(f[0] % f[1:] for f in failures)
            LOGGER.warning(__('failed to reach any of the inventories '
                              'with the following issues:') + '\n' + issues)


def fetch_inventory(app: Sphinx, uri: str, inv: str) -> Inventory:
    """Fetch, parse and return an intersphinx inventory file."""
    # both *uri* (base URI of the links to generate) and *inv* (actual
    # location of the inventory file) can be local or remote URIs
    if '://' in uri:
        # case: inv URI points to remote resource; strip any existing auth
        uri = _strip_basic_auth(uri)
    try:
        if '://' in inv:
            f = _read_from_url(inv, config=app.config)
        else:
            f = open(path.join(app.srcdir, inv), 'rb')  # NoQA: SIM115
    except Exception as err:
        err.args = ('intersphinx inventory %r not fetchable due to %s: %s',
                    inv, err.__class__, str(err))
        raise
    try:
        if hasattr(f, 'url'):
            newinv = f.url
            if inv != newinv:
                LOGGER.info(__('intersphinx inventory has moved: %s -> %s'), inv, newinv)

                if uri in (inv, path.dirname(inv), path.dirname(inv) + '/'):
                    uri = path.dirname(newinv)
        with f:
            try:
                invdata = InventoryFile.load(f, uri, posixpath.join)
            except ValueError as exc:
                raise ValueError('unknown or unsupported inventory version: %r' % exc) from exc
    except Exception as err:
        err.args = ('intersphinx inventory %r not readable due to %s: %s',
                    inv, err.__class__.__name__, str(err))
        raise
    else:
        return invdata


def _get_safe_url(url: str) -> str:
    """Gets version of *url* with basic auth passwords obscured. This function
    returns results suitable for printing and logging.

    E.g.: https://user:12345@example.com => https://user@example.com

    :param url: a url
    :type url: ``str``

    :return: *url* with password removed
    :rtype: ``str``
    """
    parts = urlsplit(url)
    if parts.username is None:
        return url
    else:
        frags = list(parts)
        if parts.port:
            frags[1] = f'{parts.username}@{parts.hostname}:{parts.port}'
        else:
            frags[1] = f'{parts.username}@{parts.hostname}'

        return urlunsplit(frags)


def _strip_basic_auth(url: str) -> str:
    """Returns *url* with basic auth credentials removed. Also returns the
    basic auth username and password if they're present in *url*.

    E.g.: https://user:pass@example.com => https://example.com

    *url* need not include basic auth credentials.

    :param url: url which may or may not contain basic auth credentials
    :type url: ``str``

    :return: *url* with any basic auth creds removed
    :rtype: ``str``
    """
    frags = list(urlsplit(url))
    # swap out 'user[:pass]@hostname' for 'hostname'
    if '@' in frags[1]:
        frags[1] = frags[1].split('@')[1]
    return urlunsplit(frags)


def _read_from_url(url: str, *, config: Config) -> IO:
    """Reads data from *url* with an HTTP *GET*.

    This function supports fetching from resources which use basic HTTP auth as
    laid out by RFC1738 § 3.1. See § 5 for grammar definitions for URLs.

    .. seealso:

       https://www.ietf.org/rfc/rfc1738.txt

    :param url: URL of an HTTP resource
    :type url: ``str``

    :return: data read from resource described by *url*
    :rtype: ``file``-like object
    """
    r = requests.get(url, stream=True, timeout=config.intersphinx_timeout,
                     _user_agent=config.user_agent,
                     _tls_info=(config.tls_verify, config.tls_cacerts))
    r.raise_for_status()
    r.raw.url = r.url
    # decode content-body based on the header.
    # ref: https://github.com/psf/requests/issues/2155
    r.raw.read = functools.partial(r.raw.read, decode_content=True)
    return r.raw
