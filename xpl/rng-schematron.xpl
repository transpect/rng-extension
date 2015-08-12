<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tr="http://transpect.io" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  version="1.0"
  name="rngsch"
  type="tr:validate-with-rng-sch">

  <p:input port="source" primary="true" />

  <p:output port="result" primary="true">
    <p:pipe step="schvalid" port="result" />
  </p:output>

  <p:output port="reports">
    <p:pipe step="wrap-reports" port="result" />
  </p:output>
  <p:serialization port="reports" indent="true"/>

  <p:output port="text">
    <p:pipe step="text-reports" port="result" />
  </p:output>
  <p:serialization port="text" method="text"/>

  <p:option name="rngfile" />
  <!-- use 1 for full namespaces in SVRL locations: -->
  <p:option name="full-path-notation" select="'2'" />
  <!-- 1: output status/info messages -->
  <p:option name="info-messages" select="'1'" />

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />

  <p:variable name="var-file-uri" select="base-uri()"/>

  <p:load name="rngfile">
    <p:with-option name="href" select="$rngfile"/>
  </p:load>
 
  <p:choose>
    <p:when test="$info-messages eq '1'">
      <cx:message>
        <p:with-option name="message" select="'RNGSCH INFO 1/5: using rngfile ', $rngfile" />
      </cx:message> 
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:sink/>

  <p:try name="rngvalid">
    <p:group>
      <p:output port="report">
        <p:pipe step="ok" port="result" />
      </p:output>
  
      <p:validate-with-relax-ng>
        <p:input port="source">
          <p:pipe step="rngsch" port="source"/>
        </p:input>
        <p:input port="schema">
          <p:pipe step="rngfile" port="result"/>
        </p:input>
      </p:validate-with-relax-ng>
      <p:sink/>

      <p:identity name="ok">
        <p:input port="source">
          <p:inline>
            <c:report>ok</c:report>
          </p:inline>
        </p:input>
      </p:identity>
    </p:group>

    <p:catch name="catch1">
      <p:output port="report">
        <p:pipe step="fwd-errors" port="result"/>
      </p:output>
  
      <p:identity name="fwd-errors">
        <p:input port="source">
          <p:pipe step="catch1" port="error" />
        </p:input>
      </p:identity>

      <p:sink/>
    </p:catch>
  </p:try>

  <p:choose>
    <p:when test="$info-messages eq '1'">
      <cx:message>
        <p:with-option name="message" select="'RNGSCH INFO 2/5: validated xml with rng'" />
      </cx:message> 
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:sink/>

  <p:xslt name="extract-sch">
    <p:input port="source">
      <p:pipe step="rngfile" port="result"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/sch-from-rng.xsl" />
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
  </p:xslt>

  <p:choose>
    <p:when test="$info-messages eq '1'">
      <cx:message>
        <p:with-option name="message" select="'RNGSCH INFO 3/5: extracted schematron from rng file'"/>
      </cx:message> 
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:add-attribute name="sch-params" attribute-name="value" match="c:param-set/c:param[@name eq 'full-path-notation']">
    <p:input port="source">
      <p:inline>
        <c:param-set>
          <c:param name="select-contexts" value="key" />
          <c:param name="full-path-notation" />
        </c:param-set>
      </p:inline>
    </p:input>
    <p:with-option name="attribute-value" select="$full-path-notation" />
  </p:add-attribute>

  <p:choose>
    <p:when test="$info-messages eq '1'">
      <cx:message>
        <p:with-option name="message" select="'RNGSCH INFO 4/5: added full-path-notation param to schematron'"/>
      </cx:message> 
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:sink/>

  <p:validate-with-schematron assert-valid="false" name="schvalid">
    <p:input port="source">
      <p:pipe step="rngsch" port="source"/>
    </p:input>
    <p:input port="schema">
      <p:pipe step="extract-sch" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe step="sch-params" port="result"/>
    </p:input>
  </p:validate-with-schematron>

  <p:choose>
    <p:when test="$info-messages eq '1'">
      <cx:message>
        <p:with-option name="message" select="'RNGSCH INFO 5/5: validated xml with schematron'" />
      </cx:message> 
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:sink/>

  <p:wrap-sequence wrapper="c:reports" name="wrap-reports">
    <p:input port="source">
      <p:pipe step="rngvalid" port="report"/>
      <p:pipe step="schvalid" port="report"/>
    </p:input>
  </p:wrap-sequence>

  <p:xslt name="text-reports">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:param name="xml-file"/>
          <xsl:param name="rng-file"/>
          <xsl:template match="/">
            <rng-sch-validation-report xml-file="{$xml-file}" rng-file="{$rng-file}">
              <xsl:apply-templates />
            </rng-sch-validation-report>
          </xsl:template>
          <xsl:template match="c:errors">
            <xsl:apply-templates />
          </xsl:template>
          <xsl:template match="c:error">
            <xsl:value-of select="@line, @column, ." separator=":" />
            <xsl:text>&#xa;</xsl:text>
          </xsl:template>
          <xsl:template match="svrl:schematron-output">
            <xsl:for-each-group select="svrl:failed-assert | svrl:successful-report" 
              group-by="concat(preceding-sibling::svrl:fired-rule[1]/@context, '__', @test)">
              <xsl:value-of select="concat('Tested &quot;', @test, '&quot; in context &quot;', replace(current-grouping-key(), '^(.+)__.+$', '$1'), '&quot;')" />
              <xsl:text>&#xa;</xsl:text>
              <xsl:apply-templates select="current-group()" />
            </xsl:for-each-group>
          </xsl:template>
          <xsl:template match="svrl:failed-assert | svrl:successful-report">
            <xsl:value-of select="concat('  ', @location)"/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:value-of select="concat('  ', .)"/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-param name="xml-file" select="$var-file-uri" />
    <p:with-param name="rng-file" select="$rngfile" />
  </p:xslt>

</p:declare-step>
