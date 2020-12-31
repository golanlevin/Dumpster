p5.js loaders for the text clips

## `clip_by_clip`

Load text files clip by clip, asynchronously. Pretty slow.

Host a local server in the folder to see a demo.

Each tiny grid represents a text file. If the file is loaded, it will light up.

Mouseover to see the content of loaded text files.


## `txtimg_loader_v1`

Load text files by parsing an image containing an encoding of them. Pretty fast.

Host a local server in the folder to see a demo.

Each tiny grid represents a text file. If the file is loaded, it will light up. Since all texts are loaded at once from one image, all grids will light up simultaneously.

Mouseover to see the content of loaded text files.

## `txtimg_loader_v2`

Same as `txtimg_loader_v1`, just with an alternative algorithm that has better compression of the data.