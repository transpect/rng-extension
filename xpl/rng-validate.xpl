<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  name="rngval"
  type="tr:validate-with-rng-sample"
  version="1.0">

  <p:documentation>Sample front-end step for tr:validate-with-rng</p:documentation>

  <p:input port="source" primary="true">
    <p:documentation>The XML document to be validated</p:documentation>
  </p:input>
  <p:input port="schema">
    <p:documentation>A Relax NG schema.</p:documentation>
  </p:input>

  <p:output primary="true" port="result">
    <p:pipe port="report" step="validate"/>
  </p:output>

  <p:import href="validate-with-rng-declaration.xpl"/>

  <tr:validate-with-rng name="validate">
    <p:input port="schema">
      <p:pipe port="schema" step="rngval"/>
    </p:input>    
  </tr:validate-with-rng>

  <p:sink/>

</p:declare-step> 
