<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:param name="base.dir">understanding/</xsl:param>
	<xsl:param name="output.dir">output/</xsl:param>
	
	<xsl:function name="wcag:isheading" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:choose>
			<xsl:when test="name($el) = 'h1' or name($el) = 'h2' or name($el) = 'h3' or name($el) = 'h4' or name($el) = 'h5' or name($el) = 'h6'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template name="name">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="name($meta) = 'guideline'">Guideline</xsl:when>
				<xsl:when test="name($meta) = 'success-criterion'">Success Criterion</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$type"/><xsl:text> </xsl:text><xsl:value-of select="$meta/num"/><xsl:text>: </xsl:text><xsl:value-of select="$meta/name"/>
	</xsl:template>
	
	<xsl:template name="navigation">
		<xsl:param name="meta" tunnel="yes"/>
		<ul id="navigation">
			<li><a href="." title="Table of Contents">Contents</a></li>
			<xsl:choose>
				<xsl:when test="name($meta) = 'guideline'">
					<xsl:if test="$meta/preceding-sibling::guideline"><li><a href="{$meta/preceding-sibling::guideline[1]/file/@href}">Previous <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/preceding-sibling::guideline[1]/name"/></a></li></xsl:if>
					<li><a href="{$meta/success-criterion[1]/file/@href}">First <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/success-criterion[1]/name"/></a></li>
					<xsl:if test="$meta/following-sibling::guideline"><li><a href="{$meta/following-sibling::guideline[1]/file/@href}">Next <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/following-sibling::guideline[1]/name"/></a></li></xsl:if>
				</xsl:when>
				<xsl:when test="name($meta) = 'success-criterion'">
					<li><a href="{$meta/parent::guideline[1]/file/@href}"><abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/parent::guideline[1]/name"/></a></li>
					<xsl:if test="$meta/preceding-sibling::success-criterion"><li><a href="{$meta/preceding-sibling::success-criterion[1]/file/@href}">Previous <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/preceding-sibling::success-criterion[1]/name"/></a></li></xsl:if>
					<xsl:if test="$meta/following-sibling::success-criterion"><li><a href="{$meta/following-sibling::success-criterion[1]/file/@href}">Next <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/following-sibling::success-criterion[1]/name"/></a></li></xsl:if>
				</xsl:when>
			</xsl:choose>
		</ul>
	</xsl:template>
	
	<xsl:template match="guidelines">
		<xsl:apply-templates select="//guideline | //success-criterion"/>
	</xsl:template>
	
	<xsl:template match="guideline | success-criterion">
		<xsl:variable name="subpath">
			<xsl:choose>
				<xsl:when test="version = 'WCAG20'">20/</xsl:when>
				<xsl:when test="version = 'WCAG21'">21/</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:message><xsl:value-of select="@id"/></xsl:message>
		<xsl:result-document href="{$output.dir}/{file/@href}" encoding="utf-8" exclude-result-prefixes="#all" indent="yes" method="xml" omit-xml-declaration="yes">
			<xsl:apply-templates select="document(resolve-uri(file/@href, concat($base.dir, $subpath)))">
				<xsl:with-param name="meta" select="." tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:html">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="lang" select="$meta/ancestor::guidelines/@lang"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
		<html lang="{$lang}" xml:lang="{$lang}">
			<head>
				<meta charset="UTF-8" />
				<xsl:apply-templates select="//html:title"/>
				<link rel="stylesheet" type="text/css" href="http://www.w3.org/StyleSheets/TR/2016/base" />
				<link rel="stylesheet" type="text/css" href="understanding.css" />
			</head>
			<body>
				<nav>
					<xsl:call-template name="navigation"/>
				</nav>
				<xsl:apply-templates select="//html:h1"/>
				<blockquote class="scquote"><xsl:copy-of select="$meta/content/html:*"/></blockquote>
				<main>
					<xsl:apply-templates select="//html:section[@id = 'intent']"/>
					<xsl:apply-templates select="//html:section[@id = 'benefits']"/>
					<xsl:apply-templates select="//html:section[@id = 'examples']"/>
					<xsl:apply-templates select="//html:section[@id = 'techniques']"/>
				</main>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="html:title | html:h1">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:copy>Understanding <xsl:call-template name="name"/></xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'intent']">
		<xsl:copy>
			<h2>Intent of <xsl:call-template name="name"/></h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.) or @id = 'benefits')]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'benefits']">
		<xsl:copy>
			<h2>Benefits of <xsl:call-template name="name"/></h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'examples']">
		<xsl:copy>
			<h2>Examples of <xsl:call-template name="name"/></h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'techniques']">
		<xsl:copy>
			<h2>Techniques for <xsl:call-template name="name"/></h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'sufficient']">
		<xsl:copy>
			<h3>Sufficient Techniques</h3>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'advisory']">
		<xsl:copy>
			<h3>Advisory Techniques</h3>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'failure']">
		<xsl:copy>
			<h3>Failures</h3>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>