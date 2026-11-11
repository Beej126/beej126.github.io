"""Conservative fixes for malformed character entities in legacy Disqus HTML."""
import re


def repair_legacy_entities(text):
    # Old Blogger/Disqus exports lost the semicolon after an encoded apostrophe,
    # including before digits: mid&amp;#3909 means mid'09, not Unicode U+9861.
    text = re.sub(r"&(?:amp;)+#0*39;?", "'", text)
    return re.sub(r"&#0*39(?![0-9;])", "'", text)
