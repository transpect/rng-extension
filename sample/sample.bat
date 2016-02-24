REM Invoke from ..\..\..\..\ (i.e., from the directory where
REM https://github.com/transpect/calabash-frontend is cloned recursively):
REM 
REM extensions\transpect\rng-extension\sample\sample.bat

calabash.bat -o result=rng-errors.xml ^
             -i source=extensions/transpect/rng-extension/sample/sample.xml ^
	     -i schema=extensions/transpect/rng-extension/sample/sample.rng ^
	     extensions/transpect/rng-extension/xpl/rng-validate.xpl
comp rng-errors.xml extensions\transpect\rng-extension\sample\rng-errors.xml

REM Apparently this invocation creates an empty c:errors file.
REM This may be related to tmp file generation in LtxValidateWithRNG.java
