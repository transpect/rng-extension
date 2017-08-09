# rng-extension
XML Calabash Relax NG validation extension step that returns a report with XPath error locations

It contains a patched jing.jar. The patch against the most recent source code available is in jing-trang.patch.

There is a test case in the `sample` diectory. From the [calabash-frontend](https://github.com/transpect/calabash-frontend) directory, invoke it using `extensions/transpect/rng-extension/sample/sample.sh` or `extensions/transpect/rng-extension/sample/sample.bat`. It should create an output file in that directory that looks exactly like [this](https://github.com/transpect/rng-extension/blob/master/sample/rng-errors.xml).

The extension class doesn’t yet use Calabash’s extension discovery annotation mechanism. There must therefore be a Calabash configuration in place. There is a configuration file in the [transpect Calabash frontend repo](https://github.com/transpect/calabash-frontend).

If you use this (and other) transpect extensions, you might need to supply them as jar files. We have included a jar file here for convenience, but we cannot guarantee that it is kept up to date wrt the source or the class file.

You can build it anew (after compiling the class) using:

```
jar cfv jar/ValidateWithRelaxNG.jar io
```