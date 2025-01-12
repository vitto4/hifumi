# Source : https://github.com/vitto4/hifumi
"""
CJK font files used in the app are quite large.
This script removes unnecessary characters to reduce bundled file size.
"""

import yaml
from fontTools import subset
from fontTools.subset import Subsetter


# ---------------------------------------------------------------------------- #
#                                 Dataset stuff                                #
# ---------------------------------------------------------------------------- #

# Load the dataset
with open("assets/dataset/minna-no-ds.yaml", "r", encoding="utf-8") as f:
    ds = yaml.load(f, Loader=yaml.FullLoader)


# Extract the keys for all available lessons
lessons: list[str] = [lesson["key"] for lesson in ds["lessons"]]


# Create the list of all words
words = []
for key in lessons:
    words.extend(ds[key])

# ---------------------------- Extract characters ---------------------------- #

# Set to store unique characters
unique_characters = set()


# Iterate through the list of words
for entry in words:
    # Add characters from 'kanji' if applicable
    if entry["kanji"] is not None:
        unique_characters.update(entry["kanji"])

    # Add characters from 'kana'
    unique_characters.update(entry["kana"])

    # Add characters from 'romaji'
    unique_characters.update(entry["romaji"])

    # Add characters from 'en' if applicable
    if entry["meaning"]["en"] is not None:
        unique_characters.update(entry["meaning"]["en"])

    # Add characters from 'fr' if applicable
    if entry["meaning"]["fr"] is not None:
        unique_characters.update(entry["meaning"]["fr"])


# Sorted list is nicer to look at
unique_characters_list = sorted(unique_characters)


# ---------------------------------------------------------------------------- #
#                                Character lists                               #
# ---------------------------------------------------------------------------- #


noto_sans_JP = "".join(unique_characters_list)  # Contains all the characters used in the dataset
noto_serif_JP = "あ"
new_tegomin = "あ字言葉準備中."


# ---------------------------------------------------------------------------- #
#                                  Subsetting                                  #
# ---------------------------------------------------------------------------- #


def make_subset(file_source: str, file_dest: str, subset_str: str):
    """Make a subset of a font file, containing only specified characters.

    Args:
        file_source (str): Path to the original font file.
        file_dest (str): Path to the output (subset) file.
        subset_str (str): String containing all characters to keep.
    """


    options = subset.Options()

    # Fail when needed, so we can take a closer look
    options.ignore_missing_glyphs = False
    options.ignore_missing_unicodes = False
    options.layout_features = "*"

    # Load the font
    font = subset.load_font(file_source, options)
    initial_glyph_count = len(font.getGlyphOrder())

    # Make subset
    subsetter = Subsetter(options=options)
    subsetter.populate(
        text=subset_str,
    )
    subsetter.subset(font)

    # Print a recap of the subset
    font_family_name = font["name"].getDebugName(1)
    final_glyph_count = len(font.getGlyphOrder())
    print(
        f"--> Subset of {font_family_name} with [  {final_glyph_count} / {initial_glyph_count}  ] glyphs."
    )

    # Save the file
    subset.save_font(font, file_dest, options)


make_subset(
    "fonts/tools/originals/NotoSansJP.original.ttf",
    "fonts/NotoSansJP.subset.ttf",
    noto_sans_JP,
)
make_subset(
    "fonts/tools/originals/NotoSerifJP.original.ttf",
    "fonts/NotoSerifJP.subset.ttf",
    noto_serif_JP,
)
make_subset(
    "fonts/tools/originals/NewTegomin-Regular.original.ttf",
    "fonts/NewTegomin-Regular.subset.ttf",
    new_tegomin,
)
