from glob import glob
import re
import numpy as np

txt = glob("text/*/*/*/*.txt")


def cleanup(f):
    f = re.sub(r' (.*?) nt ',r" \1n't ",f,flags=re.IGNORECASE);
    f = re.sub(r'& *amp;',"&",f,flags=re.IGNORECASE);
    f = re.sub(r'& *lt;',"<",f,flags=re.IGNORECASE);
    f = re.sub(r'& *gt;',">",f,flags=re.IGNORECASE);
    f = re.sub(r'font-.+?',"",f,flags=re.IGNORECASE);
    f = re.sub(r'< *span',"",f,flags=re.IGNORECASE);
    f = re.sub(r' style ?=',"",f,flags=re.IGNORECASE);
    f = re.sub(r' mso-.+? ',"",f,flags=re.IGNORECASE);
    f = re.sub(r'en-us',"",f,flags=re.IGNORECASE);
    f = re.sub(r'Times.new.roman',"",f,flags=re.IGNORECASE);
    f = re.sub(r' border-.*?-.*? ',"",f,flags=re.IGNORECASE);
    return f;

for t in txt:
    f = cleanup(open(t,'r',errors='ignore').read())
    open(t.replace("text/","text_cleaned/"),'w').write(f)