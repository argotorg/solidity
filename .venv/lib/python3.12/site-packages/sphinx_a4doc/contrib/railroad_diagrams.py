import re
import io
import math

from dataclasses import dataclass, field
from sphinx_a4doc.settings import DiagramSettings, InternalAlignment, EndClass

from typing import *

try:
    from typing.io import TextIO
except ImportError:
    from typing import TextIO


__all__ = [
    'Diagram',
    'HrefResolver',
]


T = TypeVar('T')


ESCAPE_RE = re.compile(r"[*_`\[\]<&]", re.UNICODE)


def e(text):
    return ESCAPE_RE.sub(lambda c: f'&#{ord(c[0])};', str(text))


def group_by_subsequences(items: Iterable['DiagramItem'], linebreaks: Iterable[bool]):
    subsequences: List[Tuple[int, List['DiagramItem']]] = []
    subsequence = []
    width = 0
    for item, linebreak in zip(items, linebreaks):
        subsequence.append(item)
        width += item.width
        if linebreak:
            subsequences.append((width, subsequence))
            subsequence = []
            width = 0
    if subsequence:
        subsequences.append((width, subsequence))
    return subsequences


def wrap_subsequence(items: Iterable['DiagramItem'], max_width: int):
    new_items = []
    sequence = []
    width = 0
    for item in items:
        if width + item.width > max_width:
            if sequence:
                new_items.append(sequence)
            width = item.width
            sequence = [item]
        else:
            width += item.width
            sequence.append(item)
    if sequence:
        new_items.append(sequence)
    return new_items


def ensure_type(name, x, *types):
    if not isinstance(x, types):
        types_str = ', '.join([t.__name__ for t in types])
        raise ValueError(f'{name} should be {types_str}, '
                         f'got {type(x)} ({x!r}) instead')


def ensure_empty_dict(name, x):
    if x:
        keys = ', '.join(x.keys())
        raise ValueError(f'{name} got unexpected parameters: {keys}')


class HrefResolver:
    def resolve(self, text: str, href: Optional[str], title_is_weak: bool):
        return text, href


@dataclass
class Diagram:
    settings: DiagramSettings = field(default_factory=DiagramSettings)
    """
    Settings used to render a diagram.
    
    """

    href_resolver: HrefResolver = field(default_factory=HrefResolver)
    """
    Class that manages adding hrefs to diagram nodes.
    
    """

    def element(self, name: str, **kwargs) -> 'Element':
        return Element(self, name, **kwargs)

    def path(self, x: int, y: int) -> 'Path':
        return Path(self, x, y)

    def sequence(self, *items: 'DiagramItem',
                 autowrap: bool=False,
                 linebreaks: Iterable[bool]=None) -> 'DiagramItem':
        linebreaks = linebreaks or [False] * len(items)
        assert len(items) == len(linebreaks)

        seq = Sequence(self, list(items))

        if autowrap and seq.width > self.settings.max_width:
            subsequences = group_by_subsequences(items, linebreaks)

            new_items = []
            sequence = []
            width = 0

            for ss_width, ss in subsequences:
                if width + ss_width > self.settings.max_width:
                    if sequence:
                        new_items.append(self.sequence(*sequence))
                    if ss_width > self.settings.max_width:
                        ssss = wrap_subsequence(ss, self.settings.max_width)
                    else:
                        ssss = [ss]
                    for sss in ssss:
                        new_items.append(self.sequence(*sss))
                    width = 0
                    sequence = []
                else:
                    sequence.extend(ss)
                    width += ss_width
            if sequence:
                new_items.append(self.sequence(*sequence))
            return self.stack(*new_items)
        return seq

    def stack(self, *items: 'DiagramItem') -> 'DiagramItem':
        return Stack(self, list(items))

    def choice(self, *items: 'DiagramItem', default: int = 0):
        return Choice(self, default, list(items))

    def optional(self, item: 'DiagramItem', skip: bool = False) -> 'DiagramItem':
        return self.choice(self.skip(), item, default=0 if skip else 1)

    def one_or_more(self, item: 'DiagramItem', repeat: Optional['DiagramItem'] = None) -> 'DiagramItem':
        return OneOrMore(self, item, repeat)

    def zero_or_more(self, item: 'DiagramItem', repeat: Optional['DiagramItem'] = None) -> 'DiagramItem':
        return self.optional(self.one_or_more(item, repeat))

    def start(self) -> 'DiagramItem':
        return Start(self)

    def end(self) -> 'DiagramItem':
        return End(self)

    def node(self, text: str, href: Optional[str] = None, css_class: str = '', radius: int = 0, padding: int = 20, resolve: bool = False, title_is_weak: bool = False) -> 'DiagramItem':
        return Node(self, text, href, css_class, radius, padding, resolve, title_is_weak)

    def terminal(self, text: str, href: Optional[str] = None, css_class: str = '', resolve: bool = True, title_is_weak: bool = False):
        return self.node(text, href, 'node terminal ' + css_class, 10, 20, resolve, title_is_weak)

    def non_terminal(self, text: str, href: Optional[str] = None, css_class: str = '', resolve: bool = True, title_is_weak: bool = False):
        return self.node(text, href, 'node non-terminal ' + css_class, 0, 20, resolve, title_is_weak)

    def comment(self, text: str, href: Optional[str] = None):
        return self.node(text, href, 'node comment', 0, 5)

    def literal(self, text: str):
        return self.node(text, None, 'node literal', 10, 20)

    def range(self, text: str):
        return self.node(text, None, 'node range', 10, 20)

    def charset(self, text: str):
        return self.node(text, None, 'node charset', 10, 20)

    def wildcard(self, text: str):
        return self.node(text, None, 'node wildcard', 10, 20)

    def negation(self, text: str):
        return self.node(text, None, 'node negation', 10, 20)

    def skip(self) -> 'DiagramItem':
        return Skip(self)

    def load(self, structure) -> 'DiagramItem':
        """
        Loa diagram from object (usually a parsed yaml/json).

        """
        if structure is None:
            return self.skip()
        elif isinstance(structure, str):
            return self._load_terminal(structure, {})
        elif isinstance(structure, list):
            return self._load_sequence(structure, {})
        elif isinstance(structure, dict):
            ctors = {
                'sequence': self._load_sequence,
                'stack': self._load_stack,
                'choice': self._load_choice,
                'optional': self._load_optional,
                'one_or_more': self._load_one_or_more,
                'zero_or_more': self._load_zero_or_more,
                'node': self._load_node,
                'terminal': self._load_terminal,
                'non_terminal': self._load_non_terminal,
                'comment': self._load_comment,
                'literal': self._load_literal,
                'range': self._load_range,
                'charset': self._load_charset,
                'wildcard': self._load_wildcard,
                'negation': self._load_negation,
            }

            ctors_found = []

            for name in structure:
                if name in ctors:
                    ctors_found.append(name)

            if len(ctors_found) != 1:
                raise ValueError(f'cannot determine type for {structure!r}')

            name = ctors_found[0]
            structure = structure.copy()
            arg = structure.pop(name)
            return ctors[name](arg, structure)
        else:
            raise ValueError(f'diagram item description should be string, '
                             f'list or object, got {type(structure)} instead')

    def _load_sequence(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.sequence, (list, tuple,), self._from_list,
            {
                'autowrap':      ((bool,                 ), None           ),
                'linebreaks':    ((list, tuple,          ), None           ),
            }
        )

    def _load_stack(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.stack, (list, tuple,), self._from_list,
            {
            }
        )

    def _load_choice(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.choice, (list, tuple,), self._from_list,
            {
                'default':       ((int,                  ), None           ),
            }
        )

    def _load_optional(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.optional, (str, dict, list, tuple), self._from_dict,
            {
                'skip':          ((bool,                 ), None           ),
            }
        )

    def _load_one_or_more(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.one_or_more, (str, dict, list, tuple), self._from_dict,
            {
                'repeat':        ((str, dict, list, tuple), self.load      ),
            }
        )

    def _load_zero_or_more(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.zero_or_more, (str, dict, list, tuple), self._from_dict,
            {
                'repeat':        ((str, dict, list, tuple), self.load      ),
            }
        )

    def _load_node(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.node, (str,), lambda s: ([s], {}),
            {
                'href':          ((str,                  ), None           ),
                'css_class':     ((str,                  ), None           ),
                'radius':        ((int,                  ), None           ),
                'padding':       ((int,                  ), None           ),
                'resolve':       ((bool,                 ), None           ),
                'title_is_weak': ((bool,                 ), None           ),
            }
        )

    def _load_terminal(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.terminal, (str,), lambda s: ([s], {}),
            {
                'href':          ((str,                  ), None           ),
                'css_class':     ((str,                  ), None           ),
                'resolve':       ((bool,                 ), None           ),
                'title_is_weak': ((bool,                 ), None           ),
            }
        )

    def _load_non_terminal(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.non_terminal, (str,), lambda s: ([s], {}),
            {
                'href':          ((str,                  ), None           ),
                'css_class':     ((str,                  ), None           ),
                'resolve':       ((bool,                 ), None           ),
                'title_is_weak': ((bool,                 ), None           ),
            }
        )

    def _load_comment(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.comment, (str,), lambda s: ([s], {}),
            {
                'href':          ((str,                  ), None           ),
            }
        )

    def _load_literal(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.literal, (str,), lambda s: ([s], {}),
            {
            }
        )

    def _load_range(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.range, (str,), lambda s: ([s], {}),
            {
            }
        )

    def _load_charset(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.charset, (str,), lambda s: ([s], {}),
            {
            }
        )

    def _load_wildcard(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.wildcard, (str,), lambda s: ([s], {}),
            {
            }
        )

    def _load_negation(self, a, kw) -> 'DiagramItem':
        return self._load_generic(
            a, kw, self.negation, (str,), lambda s: ([s], {}),
            {
            }
        )

    def _load_skip(self, a, kw) -> 'DiagramItem':
        return self.skip()

    def _load_generic(self, user_a, user_kw, ctor, primary_type, primary_loader,
                      spec: Dict[str, Tuple[tuple, callable]]):
        ensure_type(f'{ctor.__name__} content', user_a, *primary_type)

        a, kw = primary_loader(user_a)

        user_kw = user_kw.copy()

        for name, (types, loader) in spec.items():
            if name not in user_kw:
                continue

            arg = user_kw.pop(name)

            if arg is None:
                continue

            ensure_type(f'{ctor.__name__}\'s parameter {name}', arg, *types)

            if loader is not None:
                arg = loader(arg)

            kw[name] = arg

        ensure_empty_dict(ctor.__name__, user_kw)

        return ctor(*a, **kw)

    def _from_list(self, x):
        return [self.load(i) for i in x], {}

    def _from_dict(self, x):
        return [self.load(x)], {}

    @overload
    def render(self, root: 'DiagramItem', output: None = None, style=None) -> str: ...

    @overload
    def render(self, root: 'DiagramItem', output: TextIO, style=None) -> None: ...

    def render(self, root, output=None, style=None):
        root = self.sequence(
            self.start(),
            root,
            self.end()
        )

        # Root reference point
        x = self.settings.padding[3]
        y = self.settings.padding[2] + root.up

        # SVG dimensions
        width = self.settings.padding[1] + self.settings.padding[3] + root.width
        height = self.settings.padding[0] + self.settings.padding[2] + root.height + root.up + root.down

        svg = self.element('svg')
        svg.attrs['width'] = str(width)
        svg.attrs['height'] = str(height)
        svg.attrs['viewBox'] = f'0 0 {width} {height}'
        svg.attrs['class'] = 'railroad-diagram'
        svg = svg.format()

        if style:
            style_r = self.element('style').format()
            style_r.children.append(style)
            style_r.add_to(svg)

        g = self.element('g')
        if self.settings.translate_half_pixel:
            g.attrs['transform'] = 'translate(.5 .5)'
        g = g.format().add_to(svg)

        root.format(x, y, root.width, False, self.settings.internal_alignment).add_to(g)

        if output is None:
            output = io.StringIO()
            svg.write_svg(output)
            output.seek(0)
            return output.read()
        else:
            svg.write_svg(output)

    def __repr__(self):
        return super().__repr__()


@dataclass
class FormattedItem:
    diagram_item: 'DiagramItem'
    """Node that this element is formatted from"""

    children: List[Union['FormattedItem', str]] = field(default_factory=list)
    """Children SVG nodes"""

    def add_to(self, parent: 'FormattedItem') -> 'FormattedItem':
        parent.children.append(self)
        return self

    def write_svg(self, f: TextIO):
        f.write(f'<{self.diagram_item.name}')
        for name, value in sorted(self.diagram_item.attrs.items()):
            f.write(f' {name}="{e(value)}"')
        f.write(f' data-dbg-cls="{self.diagram_item.__class__.__name__}"'
                f' data-dbg-w="{self.diagram_item.width}"')
        f.write('>')
        for child in self.children:
            if isinstance(child, FormattedItem):
                child.write_svg(f)
            else:
                f.write(e(child))
        f.write(f'</{self.diagram_item.name}>')


# TODO: make diagram items frozen

@dataclass
class DiagramItem:
    diagram: Diagram
    """Diagram that this item is attached to"""

    name: str
    """Name of SVG node"""

    width: int = 0
    """Total width of the item"""

    height: int = 0
    """Distance between the entry/exit lines"""

    up: int = 0
    """Distance it projects above the entry line"""

    down: int = 0
    """Distance it projects below the exit line"""

    attrs: Dict[str, str] = field(default_factory=dict)
    """SVG node attributes"""

    needs_space: bool = False
    """Add extra space around this element"""

    @property
    def settings(self) -> DiagramSettings:
        return self.diagram.settings

    @property
    def href_resolver(self) -> HrefResolver:
        return self.diagram.href_resolver

    @property
    def dia(self) -> Diagram:
        return self.diagram

    def format(self, x, y, width, reverse, alignment_override) -> FormattedItem:
        """
        Prepare the component for rendering, populate children array.

        - `x` and `y` determine the reference (top-left) point of the component.
        - `width` determine total width available for rendering the component.
        - `reverse` is true if the component should be mirrored along y axis.

        For normal rendering (the reference point is marked with `#`)::

            |<-----width----->|

                +---------+      ---
                |         |       up
            --->#-------\ |      ---        < y
                | /-----/ |       height
                | \-------|--->  ---
                |         |       down
                +---------+      ---

                ^
                x

        For reverse rendering (the reference point is marked with `#`)::

            |<-----width----->|

                +---------+      ---
                |         |       up
                # /-------|<---  ---        < y
                | \-----\ |       height
            <---|-------/ |      ---
                |         |       down
                +---------+      ---

                ^
                x

        """
        raise NotImplementedError()

    def determine_gaps(self, outer, internal_alignment):
        if internal_alignment == InternalAlignment.AUTO_LEFT:
            internal_alignment = InternalAlignment.LEFT
        elif internal_alignment == InternalAlignment.AUTO_RIGHT:
            internal_alignment = InternalAlignment.RIGHT
        diff = outer - self.width
        if internal_alignment == InternalAlignment.LEFT:
            return 0, diff
        elif internal_alignment == InternalAlignment.RIGHT:
            return diff, 0
        else:
            return math.floor(diff / 2), math.ceil(diff / 2)

    def alignment_override_center(self):
        if self.settings.internal_alignment == InternalAlignment.AUTO_RIGHT:
            return InternalAlignment.CENTER
        if self.settings.internal_alignment == InternalAlignment.AUTO_LEFT:
            return InternalAlignment.CENTER
        return self.settings.internal_alignment

    def alignment_override_reverse(self, reverse):
        if not reverse:
            return self.settings.internal_alignment
        if self.settings.internal_alignment == InternalAlignment.AUTO_RIGHT:
            return InternalAlignment.AUTO_LEFT
        if self.settings.internal_alignment == InternalAlignment.AUTO_LEFT:
            return InternalAlignment.AUTO_RIGHT
        return self.settings.internal_alignment


@dataclass
class Element(DiagramItem):
    def format(self, *args, **kwargs):
        return FormattedItem(self)


@dataclass
class Path(DiagramItem):
    def __init__(self, dia: Diagram, x: int, y: int):
        super().__init__(dia, 'path')

        self.attrs = {'d': f'M{x} {y}'}

    def m(self, x, y):
        self.attrs['d'] += f'm{x} {y}'
        return self

    def h(self, val):
        self.attrs['d'] += f'h{val}'
        return self

    def right(self, val):
        return self.h(max(0, val))

    def left(self, val):
        return self.h(-max(0, val))

    def v(self, val):
        self.attrs['d'] += f'v{val}'
        return self

    def arc(self, sweep):
        arc_radius = self.settings.arc_radius

        x = arc_radius
        y = arc_radius
        if sweep[0] == 'e' or sweep[1] == 'w':
            x *= -1
        if sweep[0] == 's' or sweep[1] == 'n':
            y *= -1
        cw = 1 if sweep in ['ne', 'es', 'sw', 'wn'] else 0
        self.attrs['d'] += f'a{arc_radius} {arc_radius} 0 0 {cw} {x} {y}'
        return self

    def format(self, *args, **kwargs):
        return FormattedItem(self)


@dataclass
class Stack(DiagramItem):
    items: List[DiagramItem] = None
    skipped: Set[int] = None

    def __init__(self, dia: Diagram, items: List[DiagramItem]):
        super().__init__(dia, 'g')

        if len(items) < 1:
            items = [self.dia.skip()]

        self.skipped = set()

        for i in range(len(items)):
            if not isinstance(items[i], Sequence):
                items[i] = self.dia.sequence(items[i])

        if len(items) > 1:
            for i in range(1, len(items)):
                item = items[i]
                if isinstance(item, Sequence) and len(item.items) == 1:
                    item = item.items[0]
                if (
                    isinstance(item, Choice) and
                    len(item.items) == 2 and
                    (
                        isinstance(item.items[0], Skip) or
                        isinstance(item.items[1], Skip)
                    )
                ):
                    self.skipped.add(i)
                    if isinstance(item.items[0], Skip):
                        items[i] = item.items[1]
                    else:
                        items[i] = item.items[0]

        self.items = items

        self.up = items[0].up
        self.down = items[-1].down

        last = len(self.items) - 1
        vertical_separation = self.settings.vertical_separation
        arc_radius = self.settings.arc_radius

        for i, item in enumerate(items):
            self.width = max(self.width, item.width)

            self.height += item.height

            if i < last:
                self.height += max(arc_radius * 2,
                                   item.down + 2 * vertical_separation)
                self.height += max(arc_radius * 2,
                                   items[i + 1].up + 2 * vertical_separation)
            elif i in self.skipped:
                # In this case, the end of the stack will look like:
                #
                #  v
                #  |    +-----------+
                #  \---># last-elem |->--\
                #  |    +-----------+    |
                #  \---------------------\--->
                #
                self.down = 0
                self.height += max(arc_radius, item.down + vertical_separation)
                self.height += arc_radius
                if self.settings.internal_alignment == InternalAlignment.CENTER:
                    self.width += arc_radius
                elif self.width < item.width + arc_radius:
                    self.width += arc_radius

        if len(self.items) > 1:
            self.width += self.settings.arc_radius * 2
            # Add a little bit of extra space on edges ...
            self.width += self.settings.horizontal_separation
            # ... and bottom of the diagram
            self.down += vertical_separation

    def format(self, x, y, width, reverse, alignment_override):
        fmt = FormattedItem(self)

        left_gap, right_gap = self.determine_gaps(width, alignment_override)

        alignment_override = self.settings.internal_alignment
        if alignment_override != InternalAlignment.CENTER:
            if reverse:
                alignment_override = InternalAlignment.RIGHT
            else:
                alignment_override = InternalAlignment.LEFT

        # Input line y coordinate
        y_in = y
        # Output line y coordinate
        y_out = y + self.height

        if reverse:
            y_in, y_out = y_out, y_in

        self.dia.path(x, y_in) \
            .h(left_gap) \
            .format() \
            .add_to(fmt)
        self.dia.path(x + left_gap + self.width, y_out) \
            .h(right_gap) \
            .format() \
            .add_to(fmt)

        x += left_gap

        if len(self.items) > 1:
            self.dia.path(x, y_in) \
                .h(self.settings.arc_radius) \
                .format() \
                .add_to(fmt)
            self.dia.path(x + self.width, y_out) \
                .h(-self.settings.arc_radius) \
                .format() \
                .add_to(fmt)
            inner_width = self.width - self.settings.arc_radius * 2
            x += self.settings.arc_radius
            if len(self.items) - 1 in self.skipped:
                if self.settings.internal_alignment == InternalAlignment.CENTER:
                    # When the last element is skipped and the stack
                    # is centered, it looks like this:
                    #
                    #      +----+
                    # -----| E1 |----\
                    #      +----+    |
                    # /--------------/
                    # |  +--------+
                    # \--|   E2   |--\
                    # |  +--------+  |
                    # \--------------\---
                    #
                    #                |   |
                    #                  ^
                    # This extra bit of space is what we're removing from
                    # the inner width.
                    if reverse:
                        x += self.settings.arc_radius
                    inner_width -= self.settings.arc_radius
        else:
            inner_width = self.width

        current_y = y

        last = len(self.items) - 1
        vertical_separation = self.settings.vertical_separation
        arc_radius = self.settings.arc_radius

        for i, item in enumerate(self.items):
            if self.settings.internal_alignment == InternalAlignment.CENTER:
                elem_width = inner_width
            elif len(self.items) > 1:
                elem_width = item.width + self.settings.horizontal_separation
            else:
                elem_width = item.width
            if reverse:
                x_of = x + inner_width - elem_width
            else:
                x_of = x

            item.format(x_of, current_y, elem_width, reverse, alignment_override) \
                .add_to(fmt)

            if i < last:
                current_y += item.height

                y_1 = current_y
                current_y += max(arc_radius * 2,
                                 item.down + 2 * vertical_separation)
                y_2 = current_y
                current_y += max(arc_radius * 2,
                                 self.items[i + 1].up + 2 * vertical_separation)
                y_3 = current_y

                if reverse:
                    if i in self.skipped:
                        self.dia.path(x_of + elem_width + arc_radius, y_1 - item.height - arc_radius) \
                            .v(item.height + y_3 - y_1) \
                            .format() \
                            .add_to(fmt)
                    self.dia.path(x_of, y_1) \
                        .arc('nw') \
                        .v(y_2 - y_1 - 2 * arc_radius) \
                        .arc('ws') \
                        .h(elem_width) \
                        .arc('ne') \
                        .v(y_3 - y_2 - 2 * arc_radius) \
                        .arc('es') \
                        .format() \
                        .add_to(fmt)
                else:
                    if i in self.skipped:
                        self.dia.path(x_of - arc_radius, y_1 - item.height - arc_radius) \
                            .v(item.height + y_3 - y_1) \
                            .format() \
                            .add_to(fmt)
                    self.dia.path(x_of + elem_width, y_1) \
                        .arc('ne') \
                        .v(y_2 - y_1 - 2 * arc_radius) \
                        .arc('es') \
                        .h(-elem_width) \
                        .arc('nw') \
                        .v(y_3 - y_2 - 2 * arc_radius) \
                        .arc('ws') \
                        .format() \
                        .add_to(fmt)
            else:
                if reverse:
                    if i in self.skipped:
                        self.dia.path(x_of + elem_width + arc_radius, current_y - arc_radius) \
                            .v(y_in - current_y) \
                            .arc('es') \
                            .h(-elem_width - arc_radius) \
                            .format() \
                            .add_to(fmt)
                        self.dia.path(x_of, current_y + item.height) \
                            .arc('nw') \
                            .v(y_in - current_y - 2 * arc_radius - item.height) \
                            .arc('es') \
                            .format() \
                            .add_to(fmt)
                    self.dia.path(x, y_in) \
                        .h(x_of - x) \
                        .format() \
                        .add_to(fmt)
                else:
                    if i in self.skipped:
                        self.dia.path(x - arc_radius, current_y - arc_radius) \
                            .v(y_out - current_y) \
                            .arc('ws') \
                            .h(elem_width + arc_radius) \
                            .format() \
                            .add_to(fmt)
                        self.dia.path(x + elem_width, current_y + item.height) \
                            .arc('ne') \
                            .v(y_out - current_y - 2 * arc_radius - item.height) \
                            .arc('ws') \
                            .format() \
                            .add_to(fmt)
                    self.dia.path(x + elem_width, y_out) \
                        .h(inner_width - elem_width) \
                        .format() \
                        .add_to(fmt)

        return fmt


@dataclass
class Sequence(DiagramItem):
    items: List[DiagramItem] = None

    def __init__(self, dia: Diagram, items: List[DiagramItem]):
        super().__init__(dia, 'g')

        if len(items) < 1:
            items = [self.dia.skip()]

        self.items = []

        for item in items:
            if isinstance(item, Sequence):
                self.items.extend(item.items)
            else:
                self.items.append(item)

        # Calculate vertical dimensions for when we're rendered normally:
        height = 0
        up = 0
        down = 0
        for item in self.items:
            up = max(up, item.up - height)
            height += item.height
            down = max(down - item.height, item.down)

        # Calculate vertical dimensions for when we're rendered in reverse:
        revheight = 0
        revup = 0
        revdown = 0
        for item in self.items[::-1]:
            revup = max(revup, item.up - revheight)
            revheight += item.height
            revdown = max(revdown - item.height, item.down)

        # Set up vertical dimensions:
        self.height = height
        self.up = max(up, revup)
        self.down = max(down, revdown)

        # Calculate width:
        for item in self.items:
            self.width += item.width
            if item.needs_space:
                self.width += self.settings.horizontal_separation * 2
        if self.items[0].needs_space:
            self.width -= self.settings.horizontal_separation
        if self.items[-1].needs_space:
            self.width -= self.settings.horizontal_separation
        self.width = math.ceil(self.width)

    def format(self, x, y, width, reverse, alignment_override):
        fmt = FormattedItem(self)

        left_gap, right_gap = self.determine_gaps(width, alignment_override)

        alignment_override = self.alignment_override_center()

        # Input line y coordinate
        y_in = y
        # Output line y coordinate
        y_out = y + self.height

        if reverse:
            y_in, y_out = y_out, y_in

        self.dia.path(x, y_in) \
            .h(left_gap) \
            .format() \
            .add_to(fmt)
        self.dia.path(x + left_gap + self.width, y_out) \
            .h(right_gap) \
            .format() \
            .add_to(fmt)

        x += left_gap

        current_x = x
        current_y = y_in

        for i, item in enumerate(self.items[::-1 if reverse else 1]):
            if item.needs_space and i > 0:
                self.dia.path(current_x, current_y) \
                    .h(self.settings.horizontal_separation) \
                    .format() \
                    .add_to(fmt)
                current_x += self.settings.horizontal_separation

            if reverse:
                ref_x = current_x
                ref_y = current_y - item.height
            else:
                ref_x = current_x
                ref_y = current_y

            item.format(ref_x, ref_y, item.width, reverse, alignment_override) \
                .add_to(fmt)

            current_x += item.width

            if reverse:
                current_y -= item.height
            else:
                current_y += item.height

            if item.needs_space and i < len(self.items) - 1:
                self.dia.path(current_x, current_y) \
                    .h(self.settings.horizontal_separation) \
                    .format() \
                    .add_to(fmt)
                current_x += self.settings.horizontal_separation

        return fmt


@dataclass
class Choice(DiagramItem):
    def __init__(self, dia: Diagram, default: int, items: List[DiagramItem]):
        assert default < len(items)
        assert len(items) >= 1

        super().__init__(dia, 'g')

        self.default = default
        self.items = items

        self.width = max(item.width for item in self.items)
        self.width += self.settings.arc_radius * 4

        self.height = self.items[default].height

        #        +------+      - <- top border
        #     /-># 0    |      -
        #     |  |      |->\   -
        #     |  +------+  |   -
        #     |            |
        #     |  +------+  |   -
        #     /-># 1    |  |   -
        #     |  |      |->\   -
        #     |  +------+  |   -
        #     |            |
        #     |  +------+  |   -
        # ----+-># 2    |  |   - <- main line
        #     |  | def  |->+-  -
        #     |  +------+  |   -
        #     |            |
        #     |  +------+  |   -
        #     \-># 3    |  |   -
        #     |  |      |->/   -
        #     |  +------+  |   -
        #     |            |
        #     |  +------+  |   -
        #     \-># 4    |  |   -
        #        |      |->/   -
        #        +------+      -

        self.up += self.items[0].up

        # Reference points along y axis for each child, relative to top border
        child_refs = []

        for i, item in enumerate(self.items):
            if i in [default - 1, default + 1]:
                arcs = self.settings.arc_radius * 2
            else:
                arcs = self.settings.arc_radius

            if i < default:
                child_refs.append(self.up)
                up = self.items[i + 1].up + self.settings.vertical_separation + item.down
                up = max(arcs, up)
                up += item.height
                self.up += up
            elif i == default:
                child_refs.append(self.up)
            else:
                down = self.items[i - 1].down + self.settings.vertical_separation + item.up
                down = max(arcs, down)
                # woof... that's asymmetric =(
                child_refs.append(self.up + self.down + down + self.height)
                down += item.height
                self.down += down

        self.down += self.items[-1].down

        # Reference points along y axis for each child, relative to main line
        self.child_refs = [c - self.up for c in child_refs]

        self.width = math.ceil(self.width)

    def format(self, x, y, width, reverse, alignment_override):
        fmt = FormattedItem(self)

        left_gap, right_gap = self.determine_gaps(width, alignment_override)

        alignment_override = self.alignment_override_reverse(reverse)

        # Input line y coordinate
        y_in = y
        # Output line y coordinate
        y_out = y + self.height

        if reverse:
            y_in, y_out = y_out, y_in

        self.dia.path(x, y_in) \
            .h(left_gap) \
            .format() \
            .add_to(fmt)
        self.dia.path(x + left_gap + self.width, y_out) \
            .h(right_gap) \
            .format() \
            .add_to(fmt)

        x += left_gap

        inner_width = self.width - self.settings.arc_radius * 4

        for i, (ref_y_rel, item) in enumerate(zip(self.child_refs, self.items)):
            # Input line of the component
            child_y_in = ref_y_rel + y
            # Output line of the component
            child_y_out = child_y_in + item.height
            # Reference point of the component
            ref_x = x + self.settings.arc_radius * 2
            ref_y = child_y_in

            if reverse:
                child_y_in, child_y_out = child_y_out, child_y_in

            if i == self.default:
                self.dia.path(x, y_in) \
                    .right(self.settings.arc_radius * 2) \
                    .format() \
                    .add_to(fmt)
                self.dia.path(ref_x + inner_width, y_out) \
                    .right(self.settings.arc_radius * 2) \
                    .format() \
                    .add_to(fmt)
            else:
                if i < self.default:
                    arcs = ['se', 'wn', 'ne', 'ws']
                    arcs_size = -self.settings.arc_radius * 2
                else:
                    arcs = ['ne', 'ws', 'se', 'wn']
                    arcs_size = self.settings.arc_radius * 2
                self.dia.path(x, y_in) \
                    .arc(arcs[0]) \
                    .v(child_y_in - y_in - arcs_size) \
                    .arc(arcs[1]) \
                    .format() \
                    .add_to(fmt)
                self.dia.path(ref_x + inner_width, child_y_out) \
                    .arc(arcs[2]) \
                    .v(y_out - child_y_out + arcs_size) \
                    .arc(arcs[3]) \
                    .format() \
                    .add_to(fmt)

            item.format(ref_x, ref_y, inner_width, reverse, alignment_override) \
                .add_to(fmt)

        return fmt


@dataclass
class OneOrMore(DiagramItem):
    item: DiagramItem = None
    repeat: DiagramItem = None

    def __init__(self, dia: Diagram, item: DiagramItem, repeat: Optional[DiagramItem]=None):
        super().__init__(dia, 'g')

        self.item = item
        self.repeat = repeat = repeat or self.dia.skip()

        self.needs_space = True

        self.width = max(item.width, repeat.width)
        self.width += self.settings.arc_radius * 2

        self.height = item.height

        self.up = item.up

        self.down = item.down + self.settings.vertical_separation + repeat.up
        self.down = max(self.settings.arc_radius * 2, self.down)
        self.down += repeat.height + repeat.down

        self.width = math.ceil(self.width)

    def format(self, x, y, width, reverse, alignment_override):
        fmt = FormattedItem(self)

        left_gap, right_gap = self.determine_gaps(width, alignment_override)

        alignment_override = self.alignment_override_center()

        inner_width = self.width - self.settings.arc_radius * 2

        #     +------+      -
        # -/->#      |      - <- input line of the main component    -------
        #  |  |      |->\-  - <- output line of the main component   ---  ^
        #  |  +------+  |   -                                         ^   |
        #  |            |                                       d_out=|   |=d_in
        #  |  +------+  |   -                                         v   |
        #  |  #      |<-/   - <- input line of the repeat component  ---  v
        #  \<-|      |      - <- output line of the repeat component -------
        #     +------+      -

        # Input line y coordinate
        y_in = y
        # Output line y coordinate
        y_out = y + self.height
        # Distance between input line of the main component
        # and output line of the repeat component
        d_in = self.height + self.down - self.repeat.down
        # Distance between output line of the main component
        # and input line of the repeat component
        d_out = self.down - self.repeat.down - self.repeat.height
        # Reference point of the main component
        main_ref_x = x + self.settings.arc_radius + left_gap
        main_ref_y = y
        # Reference point of the repeat component
        repeat_ref_x = x + self.settings.arc_radius + left_gap
        repeat_ref_y = y_out + d_out

        if reverse:
            y_in, y_out = y_out, y_in
            d_in, d_out = d_out, d_in
            # note that reference points are not changed

        self.dia.path(x, y_in) \
            .h(left_gap) \
            .format() \
            .add_to(fmt)
        self.dia.path(x + left_gap + self.width, y_out) \
            .h(right_gap) \
            .format() \
            .add_to(fmt)

        x += left_gap

        # Draw main item
        self.dia.path(x, y_in) \
            .right(self.settings.arc_radius) \
            .format() \
            .add_to(fmt)
        self.dia.path(x + self.width - self.settings.arc_radius, y_out) \
            .right(self.settings.arc_radius) \
            .format() \
            .add_to(fmt)
        self.item.format(main_ref_x, main_ref_y, inner_width, reverse, alignment_override) \
            .add_to(fmt)

        # Draw repeat item
        self.dia.path(x + self.settings.arc_radius, y_in) \
            .arc('nw') \
            .v(d_in - 2 * self.settings.arc_radius) \
            .arc('ws') \
            .format() \
            .add_to(fmt)
        self.dia.path(x + self.width - self.settings.arc_radius, y_out) \
            .arc('ne') \
            .v(d_out - 2 * self.settings.arc_radius) \
            .arc('es') \
            .format() \
            .add_to(fmt)
        self.repeat.format(repeat_ref_x, repeat_ref_y, inner_width, not reverse, alignment_override) \
            .add_to(fmt)

        return fmt


@dataclass
class Start(DiagramItem):
    end_class: EndClass = None

    def __init__(self, dia: Diagram, end_class: Optional[EndClass] = None):
        super().__init__(dia, 'g')

        self.end_class = end_class or self.settings.end_class

        self.width = 20
        self.up = 10
        self.down = 10

    def format(self, x, y, width, reverse, alignment_override):
        path = self.dia.path(x, y)

        path.h(20)

        if self.end_class == EndClass.SIMPLE:
            path.m(-20, -10).v(20)
        else:
            path.m(-10, -10).v(20)
            path.m(-10, -20).v(20)

        return path.format()


@dataclass
class End(DiagramItem):
    end_class: EndClass = None

    def __init__(self, dia: Diagram, end_class: Optional[EndClass] = None):
        super().__init__(dia, 'g')

        self.end_class = end_class or self.settings.end_class

        self.width = 20
        self.up = 10
        self.down = 10

    def format(self, x, y, width, reverse, alignment_override):
        path = self.dia.path(x, y)

        path.h(20)

        if self.end_class == EndClass.SIMPLE:
            path.m(0, -10).v(20)
        else:
            path.m(0, -10).v(20)
            path.m(-10, -20).v(20)

        return path.format()


@dataclass
class Node(DiagramItem):
    text: str = None
    href: Optional[str] = None
    radius: int = None

    def __init__(self, dia: Diagram, text, href=None, css_class='', radius=0, padding=20, resolve=True, title_is_weak=False):
        super().__init__(dia, 'g')

        self.text = text
        self.href = href
        self.radius = radius
        self.resolve = resolve
        self.title_is_weak = title_is_weak

        if self.resolve:
            self.text, self.href = self.href_resolver.resolve(
                self.text, self.href, self.title_is_weak
            )

        self.attrs = {'class': css_class}
        self.needs_space = True
        self.up = 11
        self.down = 11

        self.width = len(self.text) * self.settings.character_advance + padding

        self.width = math.ceil(self.width)

    def format(self, x, y, width, reverse, alignment_override):
        fmt = FormattedItem(self)

        left_gap, right_gap = self.determine_gaps(width, alignment_override)

        self.dia.path(x, y).h(left_gap).format().add_to(fmt)
        self.dia.path(x + left_gap + self.width, y).h(right_gap).format().add_to(fmt)

        rect_attrs = {
            'x': x + left_gap,
            'y': y - self.up,
            'width': self.width,
            'height': self.up + self.down,
            'rx': self.radius,
            'ry': self.radius
        }

        self.dia.element('rect', attrs=rect_attrs).format().add_to(fmt)

        text_attrs = {
            'x': x + left_gap + self.width / 2,
            'y': y
        }

        text = self.dia.element('text', attrs=text_attrs).format()
        text.children.append(self.text)

        if self.href is not None:
            a = self.dia.element('a', attrs={'xlink:href': self.href}).format()
            text.add_to(a)
            a.add_to(fmt)
        else:
            text.add_to(fmt)

        return fmt


@dataclass
class Skip(DiagramItem):
    def __init__(self, dia: Diagram):
        super().__init__(dia, 'g')

    def format(self, x, y, width, reverse, alignment_override):
        return self.dia.path(x, y).right(width).format()
