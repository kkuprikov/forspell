# Forspell
Forspell is an awesome spelling checker for your code documentation!
![](https://user-images.githubusercontent.com/713419/55152630-d775a600-5161-11e9-9c56-d9fb45d8a3a4.png)

It works with your comments in C, C++, Ruby sources and Markdown files.
Forspell uses [hunspell] - the most popular open source spell checking library.

You could easily integrate forspell into your CI tool!

## Features

* Supports `.rb`, `.c`, `.cxx`, `.md` files.
* Checks multiple directories or files at once.
* Could exclude any subdirectories unwanted to process.
* Supports any `hunspell` dictionary.
* Could use your custom project-specific dictionary and helps you to build it - see `--dictionary` option.
* Could output results in JSON and YAML for further processing.

## Installation

```
gem install forspell
```

### Requirements
* [libhunspell] >= 1.2.0
* [ffi] ~> 1.0

Please see [hunspell installation] instructions for you platform 


## Usage

```
forspell lib *.md
```

### Options
![](https://user-images.githubusercontent.com/713419/55172066-8201bf00-518a-11e9-8305-e228aa53912d.png)
You can provide options via CLI or setup them in `.forspell` file.

* `-e, --exclude`
Exclude some subdirectories or files.
For instance, `forspell lib *.md -e lib/skip_this LICENSE.md`

* `-d, --dictionary-name`
Use another hunspell dictionary from `lib/dictionaries` folder. Default is 'en_US'.

* `-c, --custom-dictionaries`
Use your own dictionary to prevent your project-specific slang reported as errors.

Format is `custom_word: existing_word`, please note that your `custom_word` will inherit plural form from `existing_word`.

Or you could use just `custom_word`, therefore `custom_words` will be treated as an error.

Please see `lib/forspell/ruby.dict` for more examples.

* `-f, --format`
Available formats: dictionary, readable, JSON, YAML. Default is 'readable'.

* `-l, --logfile`
Use the file instead of `STDERR`.
* `-v, --verbose`
Adds `Processing file: ...` for debug purposes.

### Okay, but we use so many fuzzy words in our project...

Guess you have a lot of specific terms - don't panic :)

* Forspell ships with `ruby.dict` "dictionary extension", treating popular Ruby terms as known words!

* Create your own custom dictionary from scratch,

* ...or simply by running:
```
forspell lib -f dictionary > custom.dict
```

Then remove actual errors from `custom.dict` and re-run forspell:

```
forspell lib -c custom.dict
```

## Integration with CI

Forspell return codes:

* 0 - when no errors found

* 1 - when there are any errors

* 2 - when it could not process with provided options, i.e. no dictionary found, no directories for checking supplied.

## Authors

* [Kirill Kuprikov](https://github.com/kkuprikov)
* [Victor Shepelev](https://github.com/zverok)

## License

MIT

## Contributing

Feel free to create an issue or open a pull request!

[hunspell]: https://en.wikipedia.org/wiki/Hunspell
[hunspell installation]: https://github.com/hunspell/hunspell
[libhunspell]: http://hunspell.sourceforge.net/
[ffi]: https://github.com/ffi/ffi
