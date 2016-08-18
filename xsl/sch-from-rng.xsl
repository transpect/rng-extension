<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:s="http://purl.oclc.org/dsdl/schematron"
  exclude-result-prefixes="rng s"
  version="2.0">

  <xsl:output indent="yes"/>

  <xsl:template match="/">
    <xsl:variable name="include" as="element(rng:grammar)">
      <xsl:apply-templates mode="include" />
    </xsl:variable>
    <s:schema queryBinding="xslt2">
      <xsl:apply-templates select="$include" mode="schematron" />
    </s:schema>
  </xsl:template>

  <xsl:template match="rng:include" mode="include">
    <xsl:apply-templates select="document(resolve-uri(@href, base-uri(.)))" mode="#current" />
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="* | @*" mode="include">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="s:*" mode="schematron" priority="2">
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="*" mode="schematron">
    <xsl:apply-templates select="*" mode="#current" />
  </xsl:template>

</xsl:stylesheet>
