<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xso="bogo"
  exclude-result-prefixes="xs c"
  version="2.0">
  
  <!--  * This stylesheet expects a c:errors document and generates
        * another stylesheet which is intended to patch the c:error 
        * messages as processing instructions into its source document. 
        * -->
  
  <xsl:param name="schema-basename" as="xs:string"/>
  
  <xsl:variable name="checking-rule-name" select="concat('RNG_', $schema-basename)"/>
  
  <xsl:namespace-alias stylesheet-prefix="xso" result-prefix="xsl"/>
  
  <xsl:template match="/c:errors">
    <xso:stylesheet version="2.0">
      <!-- so that at least an SVRL will be created, even if without significant messages -->
      <xsl:if test="not(c:error)">
        <xso:template match="/*">
          <xso:copy>
            <xso:apply-templates select="@*"/>
            <xso:processing-instruction name="letex">
              <xsl:value-of select="string-join(($checking-rule-name, 'ok'), ' ')"/>
            </xso:processing-instruction>
            <xso:apply-templates/>
          </xso:copy>
        </xso:template>
      </xsl:if>
      
      <!-- identity template -->
      <xso:template match="@*|*|processing-instruction()">
        <xso:copy>
          <xso:apply-templates select="@*, node()"/>
        </xso:copy>
      </xso:template>
      
      <xso:template match="text()[not(ancestor::*)]"/>
      
      <!-- group by xpath expressions to avoid ambiguous templates in generated stylesheet. -->
        <xsl:for-each-group select="c:error" group-by="replace(replace(@xpath, '/(\c+)', '/*:$1'), '/(\*:)\c+:', '/$1')">
          <!-- grouping key: remove namespace prefixes and use prefix wildcard -->
          <xso:template match="{current-grouping-key()}">
          <xso:copy>
            <xso:apply-templates select="@*"/>
            
            <xsl:for-each select="current-group()">
              <xso:processing-instruction name="letex">
                <xsl:value-of select="string-join(($checking-rule-name, @xpath, .), ' ')"/>
              </xso:processing-instruction>  
            </xsl:for-each>
            
            <xso:apply-templates/>
          </xso:copy>
        </xso:template>
      </xsl:for-each-group>
      
    </xso:stylesheet>
  </xsl:template>
    
</xsl:stylesheet>