# Readometer
A Swift command-line tool for estimating the reading time of articles. It works perfectly with plain text as well as markdown.

<p>
  <img src="https://img.shields.io/badge/language-swift5.8-f48041.svg?style=flat"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat"/>
  <a href="https://twitter.com/ajithrnayak">
  	<img src="https://img.shields.io/badge/contact-@ajithrnayak-blue.svg?style=flat" alt="Twitter: @ajithrnayak" />
  </a>
</p>

Features of the readometer include:

- [x] Estimates the reading time for a markdown and text file input.
- [x] Displays the word count for a markdown and text file input.

### Usage

###### [Mint](https://github.com/yonaskolb/mint)

You can install Readometer using Mint:

```
mint install ajithrnayak/Readometer
```

###### Manually

Build the tool using the release configuration, and then move the compiled binary to `/usr/local/bin` :

```bash
swift build -c release
cd .build/release
cp -f Readometer /usr/local/bin/readometer
```

### Preview

![readometer_demo](https://user-images.githubusercontent.com/3415400/230220947-19d63ef3-824c-4813-9964-85cf700a99d2.gif)


### Development

Use Xcode 14.3 and above

- `cd` into the repository
- Run
```
xed Package.swift
```
- Run:
```bash
swift run readometer --help
```

### Todo
- Use https://blog.medium.com/read-time-and-you-bc2048ab620c to improve the estimation logic.
- Improve the logic for stripping markdown syntax.
