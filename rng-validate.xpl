<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  name="rng2pi"
  type="letex:validate-with-rng-PI"
  version="1.0">

  <p:input port="source" primary="true">
    <p:documentation>If you want to convert the PIs into SVRL messages for patching at the nearest @srcpath,
      the source document must contain @srcpath attributes.</p:documentation>
  </p:input>
  <p:input port="schema"/>

  <p:output primary="true" port="result"></p:output>

  <p:try>
    <p:group>
      <p:validate-with-relax-ng name="validate" assert-valid="true">
        <p:input port="source">
          <p:pipe port="source" step="rng2pi"/>
        </p:input>
        <p:input port="schema">
          <p:pipe port="schema" step="rng2pi"/>
        </p:input>
      </p:validate-with-relax-ng>
    </p:group>
    <p:catch name="catch">
      <p:identity>
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
      </p:identity>
    </p:catch>
  </p:try>

</p:declare-step> 
