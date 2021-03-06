<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:template name="id">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="wcag:generate-id(wcag:find-heading(.))"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="version">
		<version>
			<xsl:choose>
				<xsl:when test="@class = 'sc new' or @class = 'guideline new'">WCAG21</xsl:when>
				<xsl:otherwise>WCAG20</xsl:otherwise>
			</xsl:choose>
		</version>
	</xsl:template>
	
	<xsl:template name="content">
		<content><xsl:copy-of select="*[not(name() = 'h1' or name() = 'h2' or name() = 'h3' or name() = 'h4' or name() = 'h5' or name() = 'h6' or name() = 'section' or @class = 'conformance-level' or @class = 'change')]"></xsl:copy-of></content>
	</xsl:template>
	
	<xsl:template match="html:html">
		<guidelines lang="{@lang}">
			<understanding>
				<name>Introduction to Understanding WCAG 2.1</name>
				<file href="intro.html"/>
			</understanding>
			<understanding>
				<name>Understanding Techniques for WCAG Success Criteria</name>
				<file href="understanding-techniques.html"/>
			</understanding>
			<xsl:apply-templates select="//html:section[@class='principle']"/>
			<understanding>
				<name>Understanding Conformance</name>
				<file href="conformance.html"/>
			</understanding>
			<understanding>
				<name>How to Refer to WCAG 2.1 from Other Documents</name>
				<file href="refer-to-wcag.html"/>
			</understanding>
			<understanding>
				<name>Documenting Accessibility Support for Uses of a Web Technology</name>
				<file href="documenting-accessibility-support.html"/>
			</understanding>
			<understanding>
				<name>Understanding Metadata</name>
				<file href="understanding-metadata.html"/>
			</understanding>
		</guidelines>
	</xsl:template>
	
	<xsl:template match="html:section[@class='principle']">
		<principle>
			<xsl:call-template name="id"/>
			<version>WCAG20</version>
			<num><xsl:number count="html:section[@class='principle']" format="1"/></num>
			<name><xsl:value-of select="wcag:find-heading(.)"/></name>
			<xsl:call-template name="content"/>
			<xsl:apply-templates select="html:section"/>
		</principle>
	</xsl:template>
	
	<xsl:template match="html:section[@class='guideline' or @class='guideline new']">
		<guideline>
			<xsl:call-template name="id"/>
			<xsl:call-template name="version"/>
			<num><xsl:number level="multiple" count="html:section[@class='principle']|html:section[@class='guideline' or @class = 'guideline new']" format="1.1"/></num>
			<name><xsl:value-of select="wcag:find-heading(.)"/></name>
			<xsl:call-template name="content"/>
			<file href="{wcag:generate-id(wcag:find-heading(.))}.html"/>
			<xsl:apply-templates select="html:section"/>
		</guideline>
	</xsl:template>
	
	<xsl:template match="html:section[@class='sc' or @class='sc new']">
		<success-criterion>
			<xsl:call-template name="id"/>
			<xsl:call-template name="version"/>
			<num><xsl:number level="multiple" count="html:section[@class='principle']|html:section[@class='guideline' or @class = 'guideline new']|html:section[@class='sc' or @class='sc new']" format="1.1.1"/></num>
			<name><xsl:value-of select="wcag:find-heading(.)"/></name>
			<xsl:call-template name="content"/>
			<level><xsl:value-of select="html:p[@class='conformance-level']"/></level>
			<file href="{wcag:generate-id(wcag:find-heading(.))}.html"/>
		</success-criterion>
	</xsl:template>
	
</xsl:stylesheet>