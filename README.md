# XCAssetsCop

[![Build Status](https://travis-ci.org/alaphao/xcassetscop.svg?branch=master)](https://travis-ci.org/alaphao/xcassetscop)
[![Gem Version](https://badge.fury.io/rb/xcassetscop.svg)](https://badge.fury.io/rb/xcassetscop)

XCAssetsCop is a tool to enforce specific configurations of Xcode assets.

For example, you can ensure every asset inside `Image.xcassets/icons` is rendered as template, has a single scale, and is a pdf file.

### Installing
```
gem install xcassetscop
```

or add this to your Gemfile
```
gem 'xcassetscop'
```

### Getting Started
Create a xcassetsconfig.yml, it should contain a list of objects with two properties:

- **config**: An object with your configs, check the available options on the next section
- **paths**: List of paths to apply the configs 


```yaml
---
- paths:
  - "./MyApp/Images.xcassets/icons/**/*.imageset/Contents.json"
  - "./MyApp/Images.xcassets/some_folder/**/*.imageset/Contents.json"
  config:
    template_rendering_intent: template
    image_scale: single
    same_file_and_asset_name: true
    file_extension: pdf
- paths:
  - "./MyApp/Images.xcassets/illustrations/**/*.imageset/Contents.json"
  config:
    template_rendering_intent: original
    image_scale: individual
```

Then run
```
xcassetscop lint
```

### Available Options for Config

| Key | Description |
| --- | --- |
| template_rendering_intent | Ensures the assets have a specific template_rendering_intent value. Valid values are: **template**, **original**, **default** |
| image_scale | Ensures the asset have a specific image scale value. Valid values are: **single**, **individual**, **individual_and_single** |
| preserves-vector-representation | Ensures the assets preserves or not the vector information of a PDF file |
| same_file_and_asset_name | true if you want to make sure the asset name and the file name are the same  |
| file_extension | A **string** or **symbol** of the file extension. Ensures the file has a specific extenstion. E.g: `'pdf'` |

### License

MIT
