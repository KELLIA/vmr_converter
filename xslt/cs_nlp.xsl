<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
   
    <!--<xsl:strip-space elements="*" />-->
    <xsl:output indent="no"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="pre">
            <xsl:apply-templates mode="step1"/>
        </xsl:variable>
        
        <xsl:variable name="pro">
            <xsl:apply-templates mode="step2" select="$pre"/>
        </xsl:variable>
        
        <xsl:apply-templates mode="step3" select="$pro"/>
        
    </xsl:template>
    
    <!-- 
    ############################
    #   Function-Templates
    ############################
    -->
    
    <xsl:template name="string-processing">
        <xsl:choose>
            <xsl:when test="not(normalize-space(.) = '') and ancestor::hi/@rend = 'overline'">
                <xsl:call-template name="letters">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="sign" select="'&#x305;'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(normalize-space(.) = '') and ancestor::unclear">
                <xsl:call-template name="letters">
                    <xsl:with-param name="text" select="."/>
                    <xsl:with-param name="sign" select="'&#x323;'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="normalize-space(.) = ''">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="letters">
        <xsl:param name="text" select="'Some text'"/>
        <xsl:param name="sign"/>
        <xsl:if test="$text != ''">
            <xsl:variable name="letter" select="substring($text, 1, 1)"/>
            <xsl:choose>
                <xsl:when test="$letter != ' '">
                    <!--<para><xsl:value-of select="$letter" /></para>-->
                    <xsl:value-of select="concat($letter, $sign)"/>
                    <xsl:call-template name="letters">
                        <xsl:with-param name="text" select="substring-after($text, $letter)"/>
                        <xsl:with-param name="sign" select="$sign"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$letter"/>
                    <xsl:call-template name="letters">
                        <xsl:with-param name="text" select="substring-after($text, $letter)"/>
                        <xsl:with-param name="sign" select="$sign"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    
    
    <xsl:template name="tokenizeString">
        <!--passed template parameter -->
        <xsl:param name="list"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter)">
                
                <!-- get everything in front of the first delimiter -->
                <xsl:variable name="value" select="substring-before($list, $delimiter)"/>
                <!--<xsl:value-of select="substring-before($list,$delimiter)"/>-->
                
                <xsl:call-template name="translate-value">
                    <xsl:with-param name="value" select="$value"/>
                </xsl:call-template>
                
                <xsl:call-template name="tokenizeString">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="list" select="substring-after($list, $delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$list = ''">
                        <xsl:text/>
                        <!--<xsl:text>AAAFAF</xsl:text>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!--<xsl:value-of select="$list"/>-->
                        <xsl:call-template name="translate-value">
                            <xsl:with-param name="value" select="$list"/>
                        </xsl:call-template>
                        <!--<xsl:text>AAAFAF</xsl:text>-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="translate-value">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value = 'displaced-below'"> subscript </xsl:when>
            <xsl:when test="$value = 'displaced-above'"> superscript </xsl:when>
            <xsl:when test="$value = 'rubric'"> red </xsl:when>
            <xsl:when test="$value = 'cap'"> ekthetic </xsl:when>
            <xsl:when test="$value = 'other'"> </xsl:when>
            <xsl:when test="$value = 'overline'"> </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <!--<xsl:value-of select="concat($value, ' ')"/>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
    ############################
    #   STEP 1: Preprocessing
    ############################
    -->
    
    <!-- +++++++ Default-Template +++++++ -->
    <xsl:template match="@* | node()" mode="step1">
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:call-template name="string-processing"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="step1"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- +++++++ Milestones +++++++ -->
    <xsl:template match="lb" mode="step1">
        <xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0">
            <!--<xsl:attribute name="n">
                <xsl:value-of select="concat('conv:',count(preceding::lb) + 1)"/>
            </xsl:attribute>-->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="pb" mode="step1">
        <xsl:element name="pb" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="concat('vmr:', @n)"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="cb" mode="step1">
        <xsl:element name="cb" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="concat('vmr:', @n)"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    
    <!-- +++++++ Normal-Template +++++++ -->
    <xsl:template match="availability" mode="step1">
        <xsl:element name="availability" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:choose>
                <xsl:when test=".//a[@rel = 'license']">
                    <xsl:element name="licence" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="target" select=".//a[@rel = 'license']/@href" />
                        <xsl:value-of select=".//a[@rel = 'license']"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates mode="step1" /></xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="div[@type = 'chapter']" mode="step1">
        <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>textpart</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:attribute name="n" select="concat('vmr:', @n)" />
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates mode="step1"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="hi" mode="step1">
        <xsl:variable name="childs" select="child::node()[not(normalize-space(.) = '')]"/>
        <xsl:variable name="only-child-with-same-name"
            select="parent::node()[count(child::node()[not(normalize-space(.) = '')]) = 1] and parent::hi"/>
        <xsl:variable name="encapsulating" select="count($childs) = 1 and name($childs) = name(.)"/>
        
        <!--<xsl:text>HI</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>rend: </xsl:text>
        <xsl:value-of select="@rend"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>encapsulating ?: </xsl:text>
        <xsl:value-of select="$encapsulating"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>itself a lonely hi:child ?: </xsl:text>
        <xsl:value-of select="$only-child-with-same-name"/>
        <xsl:text>&#xa;</xsl:text>
        <!-\-<xsl:text> - and encapsulating ?: </xsl:text>
        <xsl:value-of select="$only-child-with-same-name and $encapsulating"/>
        <xsl:text>&#xa;</xsl:text>-\->
        <xsl:text>If 1: FALSE and 2 TRUE then LAST HI: </xsl:text>
        <xsl:value-of select="$only-child-with-same-name and not($encapsulating)"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates />
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>######################################</xsl:text>-->
        
        <xsl:choose>
            <xsl:when test="not($encapsulating) and $only-child-with-same-name">
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <!--<xsl:attribute name="type">ENCAP</xsl:attribute>-->
                    
                    <!-- Walk all encapsulating ancestor tei:his and gather their @rend-values -->
                    <xsl:attribute name="rend">
                        <xsl:variable name="anc-rends">
                            <xsl:for-each select="ancestor::hi">
                                <!--<xsl:value-of select="@rend"/>-->
                                <!--<xsl:call-template name="translate-value">
                                    <xsl:with-param name="value" select="@rend"/>
                                </xsl:call-template>-->
                                
                                <!--<xsl:call-template name="tokenizeString">
                                    <xsl:with-param name="delimiter" select="' '"/>
                                    <xsl:with-param name="list" select="@rend"/>
                                </xsl:call-template>-->
                                
                                <xsl:value-of select="@rend"/>
                                <xsl:text> </xsl:text>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="@rend and not(@rend = 'overline')">
                                <xsl:variable name="self-rend">
                                    
                                    <!--<xsl:call-template name="tokenizeString">
                                        <xsl:with-param name="delimiter" select="' '"/>
                                        <xsl:with-param name="list" select="@rend"/>
                                    </xsl:call-template>-->
                                    
                                    <xsl:value-of select="@rend"/>
                                </xsl:variable>
                                <xsl:value-of
                                    select="concat(normalize-space($anc-rends), ' ', $self-rend)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space($anc-rends)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <!--<xsl:attribute name="vmrRendDesc">
                        <xsl:value-of select="concat(ancestor::tei:hi/@rend, ' ' ,self::node()/@rend)"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates mode="step1"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="not($encapsulating) and not($only-child-with-same-name)">
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rend">
                        <!--<xsl:call-template name="tokenizeString">
                            <xsl:with-param name="delimiter" select="' '"/>
                            <xsl:with-param name="list" select="@rend"/>
                        </xsl:call-template>-->
                        <xsl:value-of select="@rend"/>
                    </xsl:attribute>
                    <!--<xsl:attribute name="vmrRendDesc">
                        <xsl:value-of select="concat(ancestor::tei:hi/@rend, ' ' ,self::node()/@rend)"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates select="node()" mode="step1"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="step1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="msDesc" mode="step1">
        <xsl:element name="msDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates mode="step1"/>
            <xsl:element name="msContents" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="textLang" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="mainLang">
                        <xsl:value-of select="./ancestor::TEI//text/@xml:lang"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="note" mode="step1"/>
    
    <xsl:template match="text" mode="step1">
        <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates mode="step1"/>
        </xsl:element>
    </xsl:template>
    
    
    
    <!-- 
    ############################
    #   STEP 2: Processing
    ############################
    -->
    
    <!-- +++++++ Default-Template +++++++ -->
    <xsl:template match="@* | node()" mode="step2">
        <xsl:copy><xsl:apply-templates select="@* | node()" mode="step2"/></xsl:copy>
    </xsl:template>
    
    
    <!-- +++++++ Normal-Template +++++++ -->
    <xsl:template match="hi" mode="step2">
        <xsl:choose>
            <xsl:when test="not(@rend) or @rend = ''">
                <xsl:apply-templates mode="step2"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rendition" select="concat('#hiNodeRend_', count(preceding::hi) + 1)" />
                        
                    
                    <xsl:attribute name="rend">
                        <!--<xsl:value-of select="normalize-space(@rend)"/>-->
                        <xsl:call-template name="tokenizeString">
                            <xsl:with-param name="delimiter" select="' '"/>
                            <xsl:with-param name="list" select="normalize-space(@rend)"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <!-- Ignore @vmrRendDesc -->
                    <!--<xsl:attribute name="vmrRendDesc">
                        <xsl:value-of select="@vmrRendDesc"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates mode="step2" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="teiHeader" mode="step2">
        <xsl:element name="teiHeader" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates mode="step2" />
            <xsl:if test="not(child::encodingDesc)">
                <xsl:element name="encodingDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="tagsDecl" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="ancestor::TEI/text//hi">
                            <xsl:element name="rendition" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="n">
                                    <xsl:text>vmr-rendition</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="scheme">
                                    <xsl:text>free</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="concat('hiNodeRend_', count(preceding::hi) + 1)"/>
                                </xsl:attribute>
                                <xsl:value-of select="@rend"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    
    
    <!-- 
    ############################
    #   STEP 3: Postprocessing
    ############################
    -->
    
    <!-- +++++++ Default-Template +++++++ -->
    <xsl:template match="@* | node()" mode="step3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="step3"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- +++++++ Normal-Template +++++++ -->
    
    <xsl:template match="hi" mode="step3">
        <xsl:choose>
            <xsl:when test="not(@rend) or normalize-space(@rend) = ''">
                <!-- uncomment when keeping track on non-informative his -->
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rendition">
                        <xsl:value-of select="@rendition"/>
                    </xsl:attribute>
                    <xsl:apply-templates mode="step3"/>
                </xsl:element>
                
                <!--<xsl:apply-templates mode="step3"/>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rendition">
                        <xsl:value-of select="@rendition"/>
                    </xsl:attribute>
                    <xsl:attribute name="rend">
                        <xsl:value-of select="normalize-space(@rend)"/>
                    </xsl:attribute>
                    <!-- Ignore @vmrRendDesc -->
                    <!--<xsl:attribute name="vmrRendDesc">
                        <xsl:value-of select="@vmrRendDesc"/>
                    </xsl:attribute>-->
                    <xsl:apply-templates mode="step3" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="pc" mode="step3">
        <xsl:text> &#x2027; </xsl:text>
        
    </xsl:template>
    
    <xsl:template match="space[@unit = 'char' and @extent]" mode="step3">
        <xsl:element name="space" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rend">
                <xsl:value-of select="concat(@extent, '_space_right')"/>
            </xsl:attribute>
            <!--<xsl:text>&#x2027;</xsl:text>-->
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="supplied" mode="step3">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates mode="step3"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="unclear" mode="step3">
        <xsl:apply-templates mode="step3" />
    </xsl:template>
    
    <xsl:template match="w" mode="step3">
        <xsl:text>@(</xsl:text>
        <xsl:apply-templates mode="step3" />
        <xsl:text>)@</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>