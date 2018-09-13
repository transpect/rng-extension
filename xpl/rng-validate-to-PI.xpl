<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  name="rng2pi"
  type="tr:validate-with-rng-PI"
  version="1.0">

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status?enabled=false'"/>
  <p:option name="remove-srcpaths" select="'true'" required="false">
    <p:documentation>The effect of this option being true is: remove @srcpath and /*/@source-dir-uri from the source document 
      prior to validation, but use the unaltered source document for looking up the closest @srcpaths for each validation error.
      This should be set to false for validation of Hub XML and other schemas in which @srcpath and /*/@source-dir-uri are legal.
    </p:documentation>
  </p:option>
  <p:option name="remove-xml-base" select="'true'" required="false">
    <p:documentation>Similar to remove-srcpaths, only for @xml:base</p:documentation>
  </p:option>
  
  <p:input port="source" primary="true">
    <p:documentation>If you want to convert the PIs into SVRL messages for patching at the nearest @srcpath,
      the source document must contain @srcpath attributes.</p:documentation>
  </p:input>
  <p:input port="schema">
    <p:documentation>The Relax NG document must have a base-uri(/*) that ends in '.rng'</p:documentation>
  </p:input>
  <p:output port="result" primary="true"/>
  
  <p:output port="report">
    <p:pipe port="report" step="validate"/>
  </p:output>

  <p:import href="validate-with-rng-declaration.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  
  <p:variable name="schema-basename" select="replace(base-uri(/*), '^(.+/)?([^/]+)\.rng', '$2')">
    <p:pipe step="rng2pi" port="schema"/>
  </p:variable>

  <p:string-replace match="c:schema-name" name="replace-schema-name-in-start-msg">
    <p:with-option name="replace" select="concat('''', $schema-basename, '''')"/>
    <p:input port="source">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting '<c:schema-name>family</c:schema-name>' Relax NG schema validation</c:message>
          <c:message xml:lang="de">Beginne Validierung gegen das Relax-NG-Schema '<c:schema-name>family</c:schema-name>'</c:message>
        </c:messages>
      </p:inline>
    </p:input>
  </p:string-replace>
  
  <p:string-replace match="c:schema-name" name="replace-schema-name-in-success-msg">
    <p:with-option name="replace" select="concat('''', $schema-basename, '''')"/>
    <p:input port="source">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Finished '<c:schema-name>family</c:schema-name>' Relax NG schema validation</c:message>
          <c:message xml:lang="de">Validierung gegen das Relax-NG-Schema '<c:schema-name>family</c:schema-name>' abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
  </p:string-replace>
  
  <tr:simple-progress-msg name="start-msg" >
    <p:with-option name="file" select="concat('validate-with-rng-PI_', $schema-basename,'_start.txt')"/>
    <p:input port="msgs">
      <p:pipe port="result" step="replace-schema-name-in-start-msg"/>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>

  <p:identity>
    <p:input port="source">
      <p:pipe port="source" step="rng2pi"/>
    </p:input>
  </p:identity>

  <p:choose name="conditionally-strip-srcpath">
    <p:when test="$remove-srcpaths = 'true'">
      <p:delete match="@srcpath | /*/@source-dir-uri"/>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:choose name="conditionally-strip-xml-base">
    <p:when test="$remove-xml-base = 'true'">
      <p:delete match="@xml:base"/>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <tr:validate-with-rng name="validate">
    <p:input port="schema">
      <p:pipe port="schema" step="rng2pi"/>
    </p:input>
  </tr:validate-with-rng>

  <p:sink/>
  
  <tr:store-debug>
    <p:input port="source">
      <p:pipe step="validate" port="report"/>
    </p:input>
    <p:with-option name="pipeline-step" select="concat('rngvalid/', $schema-basename, '/report')"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
  <p:sink/>

  <p:xslt name="generate-patch-xslt">
    <p:input port="source">
      <p:pipe step="validate" port="report"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/create-report2pi-xsl.xsl"/>
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-param name="schema-basename" select="$schema-basename"/>
  </p:xslt>
  
  <tr:store-debug extension="xsl">
    <p:with-option name="pipeline-step" select="concat('rngvalid/', $schema-basename, '/patch')"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>  
  
  <p:sink/>
  
  <p:xslt name="create-PIs">
    <p:input port="source">
      <p:pipe port="source" step="rng2pi"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="generate-patch-xslt" port="result"/>
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
  </p:xslt>

  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('rngvalid/', $schema-basename, '/with-PIs_1')"/>
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </tr:store-debug>
  
  <tr:simple-progress-msg name="success-msg" >
    <p:with-option name="file" select="concat('validate-with-rng-PI_', $schema-basename,'_success.txt')"/>
    <p:input port="msgs">
      <p:pipe port="result" step="replace-schema-name-in-success-msg"/>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
</p:declare-step>
