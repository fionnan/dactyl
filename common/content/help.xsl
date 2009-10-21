<xsl:stylesheet version="1.0"
    xmlns="http://vimperator.org/namespaces/liberator"
    xmlns:liberator="http://vimperator.org/namespaces/liberator"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="str">

    <xsl:output method="xml"/>

    <xsl:template match="liberator:document">
        <html:html liberator:highlight="Help">
            <html:head>
                <html:title><xsl:value-of select="@title"/></html:title>
                <html:base href="liberator://help/{@name}"/>
                <html:script type="text/javascript"
                    src="chrome://liberator/content/help.js"/>
            </html:head>
            <html:body liberator:highlight="HelpBody">
                <html:div class="liberator-logo"/>
                <xsl:call-template name="parse-tags">
                    <xsl:with-param name="text" select="concat(@name, '.html')"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </html:body>
        </html:html>
    </xsl:template>

    <xsl:template match="liberator:include">
        <xsl:apply-templates select="document(@href)/liberator:document/node()"/>
    </xsl:template>

    <xsl:template match="liberator:dl">
        <xsl:copy>
            <column/>
            <column/>
            <xsl:for-each select="liberator:dt">
                <tr>
                    <xsl:apply-templates select="."/>
                    <xsl:apply-templates select="following-sibling::liberator:dd[position()=1]"/>
                </tr>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="liberator:tags">
        <xsl:call-template name="parse-tags">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="parse-tags">
        <xsl:param name="text"/>
        <tags>
        <xsl:for-each select="str:tokenize($text)">
            <html:a id="{.}"><tag><xsl:value-of select="."/></tag></html:a>
        </xsl:for-each>
        </tags>
    </xsl:template>

    <xsl:template match="liberator:default[not(@type='plain')]">
        <xsl:variable name="type" select="preceding-sibling::liberator:type[1] | following-sibling::liberator:type[1]"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="starts-with($type, 'string')">
                    <str><xsl:apply-templates/></str>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:choose>
                            <xsl:when test="$type = 'boolean'">
                                <xsl:attribute name="highlight" namespace="http://vimperator.org/namespaces/liberator">Boolean</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$type = 'number'">
                                <xsl:attribute name="highlight" namespace="http://vimperator.org/namespaces/liberator">Number</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$type = 'charlist'">
                                <xsl:attribute name="highlight" namespace="http://vimperator.org/namespaces/liberator">String</xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="linkify-tag">
        <xsl:param name="contents"/>
        <xsl:variable name="tag" select="str:tokenize($contents, ' [')[1]"/>
        <html:a href="liberator://help-tag/{$tag}" style="color: inherit">
            <xsl:if test="
                //liberator:tags[contains(concat(' ', ., ' '), concat(' ', $tag, ' '))] |
                //liberator:tag[contains(concat(' ', ., ' '), concat(' ', $tag, ' '))] |
                //@tag[contains(concat(' ', ., ' '), concat(' ', $tag, ' '))]">
                <xsl:attribute name="href">#<xsl:value-of select="$tag"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$contents"/>
        </html:a>
    </xsl:template>
    <xsl:template match="liberator:o">
        <xsl:copy>
            <xsl:call-template name="linkify-tag">
                <xsl:with-param name="contents" select='concat("&#39;", text(), "&#39;")'/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="liberator:k">
        <xsl:copy>
            <xsl:call-template name="linkify-tag">
                <xsl:with-param name="contents" select="text()"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="liberator:k[@name]">
        <xsl:copy>
            <xsl:call-template name="linkify-tag">
                <xsl:with-param name="contents" select="concat('&lt;', @name, '>', .)"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="liberator:ex">
        <xsl:copy>
            <xsl:call-template name="linkify-tag">
                <xsl:with-param name="contents" select="."/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="liberator:tag|@tag">
        <xsl:call-template name="parse-tags">
            <xsl:with-param name="text"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>

<!-- vim:se ft=xslt sts=4 sw=4 et: -->