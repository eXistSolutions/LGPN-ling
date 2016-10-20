<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output indent="yes" method="xml"/>
    <xsl:template match="/">
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Title</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
                <encodingDesc>
                    <classDecl><!-- flat taxonomy with <catDesc> entries for every language; links to appropriate ontologies realised through corresp attribute  -->
                        <taxonomy xml:id="semanticFields">
                            <xsl:variable name="interps" select="string-join(//tei:interpGrp/tei:interp[@xml:lang='en']/@ana, ', ')"/>
                            <xsl:for-each select="distinct-values(tokenize($interps, ', '))">
                                <category xml:id="{.}">
                                    <catDesc xml:lang="en">
                                        <xsl:value-of select="."/>
                                    </catDesc>
                                </category>
                            </xsl:for-each>
                        </taxonomy>
                    </classDecl>
                </encodingDesc>
                <revisionDesc>
                    <listChange>
                        <change when="2015-11-24" resp="#MT">initial transform</change>
                    </listChange>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <xsl:apply-templates select="//tei:entryFree"/>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <xsl:template match="tei:entryFree">
        <xsl:variable name="id" select="tei:form/tei:orth[@type='latin']"/>
        <entry xml:id="{$id}">
            <xsl:apply-templates/>
        </entry>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:variable name="target" select="tei:ptr/@target"/>
        <cit>
            <quote>
                <xsl:apply-templates select="text()"/>
            </quote>
            <xsl:if test="$target">
                <ref target="{$target}"/>
            </xsl:if>
        </cit>
    </xsl:template>
    <xsl:template match="tei:bibl">
        <xsl:variable name="target" select="tei:ptr/@target"/>
        <ref type="linguistic">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    <xsl:template match="tei:interpGrp"/>
    <xsl:template match="tei:m">
        <xsl:variable name="ana">
            <xsl:for-each select="tokenize(tei:interpGrp/tei:interp[@xml:lang='en']/@ana, ', ')">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:if test="string($ana)">
                <xsl:attribute name="ana" select="normalize-space($ana)"/>
            </xsl:if>
            <xsl:apply-templates select="@*|text()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:usg">
        <xsl:variable name="ana">
            <xsl:for-each select="tokenize(@type, ';')">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy copy-namespaces="no">
            <xsl:if test="string($ana)">
                <xsl:attribute name="ana" select="normalize-space($ana)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>