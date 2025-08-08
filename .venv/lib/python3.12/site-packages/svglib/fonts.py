"""
This is a collection for all the font-related code used by ``svglib`` module.
"""

import os
import subprocess
import sys

from reportlab.pdfbase.pdfmetrics import registerFont
from reportlab.pdfbase.ttfonts import TTFError, TTFont

STANDARD_FONT_NAMES = (
    'Times-Roman', 'Times-Italic', 'Times-Bold', 'Times-BoldItalic',
    'Helvetica', 'Helvetica-Oblique', 'Helvetica-Bold', 'Helvetica-BoldOblique',
    'Courier', 'Courier-Oblique', 'Courier-Bold', 'Courier-BoldOblique',
    'Symbol', 'ZapfDingbats',
)
DEFAULT_FONT_NAME = "Helvetica"
DEFAULT_FONT_WEIGHT = 'normal'
DEFAULT_FONT_STYLE = 'normal'
DEFAULT_FONT_SIZE = 12


class FontMap:
    """
    Managing the mapping of svg font names to reportlab fonts and registering
    them in reportlab.
    """

    def __init__(self):
        """
        The map has the form:
        'internal_name': {
           'svg_family': 'family_name', 'svg_weight': 'font-weight', 'svg_style': 'font-style',
           'rlgFont': 'rlgFontName'
        }
        for faster searching we use internal keys for finding the matching font
        """
        self._map = {}

        self.register_default_fonts()

    @staticmethod
    def build_internal_name(family, weight='normal', style='normal'):
        """
        If the weight or style is given, append the capitalized weight and style
        to the font name. E.g. family="Arial", weight="bold" and style="italic"
        then the internal name would be "Arial-BoldItalic", this mimics the
        default fonts naming schema.
        """
        result_name = family
        if weight != 'normal' or style != 'normal':
            result_name += '-'
        if weight != 'normal':
            if type(weight) is int:
                result_name += f'{weight}'
            else:
                result_name += weight.lower().capitalize()
        if style != 'normal':
            result_name += style.lower().capitalize()
        return result_name

    @staticmethod
    def guess_font_filename(basename, weight='normal', style='normal', extension='ttf'):
        """
        Try to guess the actual font filename depending on family, weight and style,
        this works at least for windows on the "default" fonts like, Arial,
        courier, Times New Roman etc.
        """
        prefix = ''
        is_bold = (weight.lower() == 'bold')
        is_italic = (style.lower() == 'italic')
        if is_bold and not is_italic:
            prefix = 'bd'
        elif is_bold and is_italic:
            prefix = 'bi'
        elif not is_bold and is_italic:
            prefix = 'i'
        filename = f'{basename}{prefix}.{extension}'
        return filename

    def use_fontconfig(self, font_name, weight='normal', style='normal'):
        NOT_FOUND = (None, False)
        # Searching with Fontconfig
        try:
            pipe = subprocess.Popen(
                ['fc-match', '-s', '--format=%{file}\\n', font_name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            output = pipe.communicate()[0].decode(sys.getfilesystemencoding())
        except OSError:
            return NOT_FOUND
        font_paths = output.split('\n')
        for font_path in font_paths:
            try:
                registerFont(TTFont(font_name, font_path))
            except TTFError:
                continue
            else:
                success_font_path = font_path
                break
        else:
            return NOT_FOUND
        # Fontconfig may return a default font totally unrelated with font_name
        exact = font_name.lower() in os.path.basename(success_font_path).lower()
        internal_name = FontMap.build_internal_name(font_name, weight, style)
        self._map[internal_name] = {
            'svg_family': font_name, 'svg_weight': weight,
            'svg_style': style, 'rlgFont': font_name, 'exact': exact,
        }
        return font_name, exact

    def register_default_fonts(self):
        self.register_font("Times New Roman", rlgFontName="Times-Roman")
        self.register_font("Times New Roman", weight="bold", rlgFontName="Times-Bold")
        self.register_font("Times New Roman", style="italic", rlgFontName="Times-Italic")
        self.register_font(
            "Times New Roman", weight="bold", style="italic", rlgFontName="Times-BoldItalic"
        )

        self.register_font("Helvetica", rlgFontName="Helvetica")
        self.register_font("Helvetica", weight="bold", rlgFontName="Helvetica-Bold")
        self.register_font("Helvetica", style="italic", rlgFontName="Helvetica-Oblique")
        self.register_font(
            "Helvetica", weight="bold", style="italic", rlgFontName="Helvetica-BoldOblique"
        )

        self.register_font("Courier New", rlgFontName="Courier")
        self.register_font("Courier New", weight="bold", rlgFontName="Courier-Bold")
        self.register_font("Courier New", style="italic", rlgFontName="Courier-Oblique")
        self.register_font(
            "Courier New", weight="bold", style="italic", rlgFontName="Courier-BoldOblique"
        )
        self.register_font("Courier", style="italic", rlgFontName="Courier-Oblique")
        self.register_font(
            "Courier", weight="bold", style="italic", rlgFontName="Courier-BoldOblique"
        )

        self.register_font("sans-serif", rlgFontName="Helvetica")
        self.register_font("sans-serif", weight="bold", rlgFontName="Helvetica-Bold")
        self.register_font("sans-serif", style="italic", rlgFontName="Helvetica-Oblique")
        self.register_font(
            "sans-serif", weight="bold", style="italic", rlgFontName="Helvetica-BoldOblique"
        )

        self.register_font("serif", rlgFontName="Times-Roman")
        self.register_font("serif", weight="bold", rlgFontName="Times-Bold")
        self.register_font("serif", style="italic", rlgFontName="Times-Italic")
        self.register_font("serif", weight="bold", style="italic", rlgFontName="Times-BoldItalic")

        self.register_font("times", rlgFontName="Times-Roman")
        self.register_font("times", weight="bold", rlgFontName="Times-Bold")
        self.register_font("times", style="italic", rlgFontName="Times-Italic")
        self.register_font("times", weight="bold", style="italic", rlgFontName="Times-BoldItalic")

        self.register_font("monospace", rlgFontName="Courier")
        self.register_font("monospace", weight="bold", rlgFontName="Courier-Bold")
        self.register_font("monospace", style="italic", rlgFontName="Courier-Oblique")
        self.register_font(
            "monospace", weight="bold", style="italic", rlgFontName="Courier-BoldOblique"
        )

    def register_font_family(self, family, normal,  bold=None, italic=None, bolditalic=None):
        self.register_font(family, normal)
        if bold is not None:
            self.register_font(family, bold, weight='bold')
        if italic is not None:
            self.register_font(family, italic, style='italic')
        if bolditalic is not None:
            self.register_font(family, bolditalic, weight='bold', style='italic')

    def register_font(
        self, font_family, font_path=None, weight='normal', style='normal', rlgFontName=None
    ):
        """
        Register a font identified by its family, weight and style linked to an
        actual fontfile. Or map an svg font family, weight and style combination
        to a reportlab fontname.
        """
        NOT_FOUND = (None, False)
        internal_name = FontMap.build_internal_name(font_family, weight, style)
        if rlgFontName is None:
            # if no reportlabs font name is given, use the internal fontname to
            # register the reportlab font
            rlgFontName = internal_name

        if rlgFontName in STANDARD_FONT_NAMES:
            # mapping to one of the standard fonts, no need to register
            self._map[internal_name] = {
                'svg_family': font_family, 'svg_weight': weight,
                'svg_style': style, 'rlgFont': rlgFontName, 'exact': True,
            }
            return internal_name, True

        if internal_name not in STANDARD_FONT_NAMES and font_path is not None:
            try:
                registerFont(TTFont(rlgFontName, font_path))
                self._map[internal_name] = {
                    'svg_family': font_family, 'svg_weight': weight,
                    'svg_style': style, 'rlgFont': rlgFontName, 'exact': True,
                }
                return internal_name, True
            except TTFError:
                return NOT_FOUND

    def find_font(self, font_name, weight='normal', style='normal'):
        """Return the font and a Boolean indicating if the match is exact."""
        internal_name = FontMap.build_internal_name(font_name, weight, style)
        # Step 1 check if the font is one of the buildin standard fonts
        if internal_name in STANDARD_FONT_NAMES:
            return internal_name, True
        # Step 2 Check if font is already registered
        if internal_name in self._map:
            return self._map[internal_name]['rlgFont'], self._map[internal_name]['exact']
        # Step 3 Try to auto register the font
        # Try first to register the font if it exists as ttf
        guessed_filename = FontMap.guess_font_filename(font_name, weight, style)
        reg_name, exact = self.register_font(font_name, guessed_filename)
        if reg_name is not None:
            return reg_name, exact
        return self.use_fontconfig(font_name, weight, style)


_font_map = FontMap()  # the global font map


def register_font(font_name, font_path=None, weight='normal', style='normal', rlgFontName=None):
    """
    Register a font by name or alias and path to font including file extension.
    """
    return _font_map.register_font(font_name, font_path, weight, style, rlgFontName)


def find_font(font_name, weight='normal', style='normal'):
    """Return the font and a Boolean indicating if the match is exact."""
    return _font_map.find_font(font_name, weight, style)


def register_font_family(self, family, normal,  bold=None, italic=None, bolditalic=None):
    _font_map.register_font_family(family, normal, bold, italic, bolditalic)


def get_global_font_map():
    return _font_map
