# Invoke from ../../../../ (i.e., from the directory where
# https://github.com/transpect/calabash-frontend is cloned recursively):
#
# extensions/transpect/rng-extension/sample/sample.sh

./calabash.sh -o result=rng-errors.xml \
	      -i source=extensions/transpect/rng-extension/sample/sample.xml \
	      -i schema=extensions/transpect/rng-extension/sample/sample.rng \
	      extensions/transpect/rng-extension/xpl/rng-validate.xpl
diff -s rng-errors.xml extensions/transpect/rng-extension/sample/
