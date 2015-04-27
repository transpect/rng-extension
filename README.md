# rng-extension
XML Calabash Relax NG validation extension step that returns a report with XPath error locations

It contains a patched jing.jar. The patch against the most recent source code available is in jing-trang.patch.

The extension class doesn’t yet use Calabash’s extension discovery annotation mechanism. There must therefore be a Calabash configuration in place. There is a configuration file in the [transpect Calabash frontend repo](https://github.com/transpect/calabash-frontend).
