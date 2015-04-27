<?xml version="1.0"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io" 
  version="1.0" 
  type="tr:validate-with-rng" 
  name="validate-with-rng">
  <p:documentation>Provides advanced Relax NG validation in that it returns a report (you don’t have to try/catch in order
  to get the errors) and that each error has its location in the document expressed as XPath instead of line numbers.
  The necessity for XPath locations arises when you validate documents that consist of a single line or documents that are 
  created in memory. We wonder why no one has thought of this in the original SAX error specification.</p:documentation>
  <p:input port="source" primary="true">
    <p:documentation>Any XML document.</p:documentation>
  </p:input>
  <p:input port="schema">
    <p:documentation>A Relax NG schema.</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>The input document.</p:documentation>
  </p:output>
  <p:output port="report">
    <p:documentation>A c:errors document with c:error elements for each validation error.
    Each c:error element contains the attributes xpath (error location) and code (error code).
    Jing’s error message is the content of an c:error element.</p:documentation>
  </p:output>
</p:declare-step>
