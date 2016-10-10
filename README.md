# foldername-tabs package

Adds foldernames to tabs..

| Theme | Appearance |
| -----:| :----------|
| atom | ![fnt-atom](https://cloud.githubusercontent.com/assets/1881921/8182308/7b0d9572-142e-11e5-91fa-6a5ed02eac32.png) |
| graphite | ![fnt-graphite](https://cloud.githubusercontent.com/assets/1881921/8182309/7b287c70-142e-11e5-822f-a714b1bfb945.png) |
| isotope | ![fnt-isotope](https://cloud.githubusercontent.com/assets/1881921/8182310/7b37b5c8-142e-11e5-8446-bae30d303235.png) |
| one | ![fnt-one](https://cloud.githubusercontent.com/assets/1881921/8182311/7b398b00-142e-11e5-8a27-9e179e285a5c.png) |
| polymorph | ![fnt-polymorph](https://cloud.githubusercontent.com/assets/1881921/8182312/7b41b83e-142e-11e5-93e7-27c21c9a2bf0.png) |
| seti | ![fnt-seti](https://cloud.githubusercontent.com/assets/1881921/8182313/7b42d0fc-142e-11e5-9aa0-f8a62711305c.png) |

Will be automatically enabled once installed. Can be toggled but will re-enable on restart.

## Current folder naming schema:

```
## outside of your project
folder: /.../lastFolder

## within your project
folder: empty # In root folder
folder: lastFolder # directly below root
folder: ../../lastFolder # nested below root

## within your multi-folder project
# like in a single-folder project but each folder gets the number of the root
# folder prepended. Can be set to use a short name instead of a number.
```
### Settings

![foldername-settings](https://cloud.githubusercontent.com/assets/1881921/8568995/600b0c7c-2573-11e5-8b6a-02afec61cc9c.png)

Available settings:
```coffee
"Maximum path length":
  default: 20
  description: "Allowed length of a path, if set to 0, will not shorten the path"
"Maximum folder length":
  default: 0
  description: "Allowed length of a single folder, if set to 0, will not shorten the folder"
"Multi-folder project identifier":
  default: 0
  description: "length of the project identifier, if set to 0 will use numbers instead"
"Filename first"
  default: false
  description: "Puts the filename above the foldername"
```
## Developing

Run `npm install` in the package directory.

Open it in atom in dev mode.

For debugging set the debug field in package settings to the needed debug level.

Should autoreload the package on changes in `lib` and `styles` folders


## License
Copyright (c) 2015 Paul Pflugradt
Licensed under the MIT license.
