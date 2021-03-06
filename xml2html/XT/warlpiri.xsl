<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          version="1.0"
	  xmlns:html="http://www.w3.org/TR/REC-html40/"
	  result-ns="">

<!-- This version redeveoped by Chris Manning for April 99 XSL draft -->
<!-- July 1999 -->

<!-- order is ROOT, ENTRY, HW, then rest alphabetically (all *I under CFI) -->

<!-- note that link colors are now similar but not exactly matching -
     the idea was to enhance readability (darker colous) -->

<xsl:template match="/" xml:space="preserve">
<HTML>
<HEAD>
<TITLE><xsl:apply-templates select='DICTIONARY/ENTRY/HW'/></TITLE>
</HEAD>
<BODY BGCOLOR="#F0F0F0" LINK="#6E6761" VLINK="#551A8B">
  <xsl:apply-templates/>
</BODY>
</HTML>
</xsl:template>


<xsl:template match="ENTRY">
  <!-- The funny test here is because the HW is also used in the
      title, and Java HtmlPane barfs on tags in the title... -->
  <H1>
  <xsl:choose>
    <xsl:when test='HW/@TYPE'>
      <I><xsl:apply-templates select='HW'/></I>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select='HW'/>
    </xsl:otherwise>
  </xsl:choose>
  </H1>
  <xsl:text>
</xsl:text>
  <xsl:apply-templates select='GL'/>
  <xsl:text>
</xsl:text>
  <xsl:apply-templates select='DEF'/>
  <xsl:text>
</xsl:text>
  <xsl:apply-templates select='EXAMPLES'/>
  <xsl:apply-templates select='PDX'/>
  <!-- links -->
  <xsl:apply-templates select='XME'/>
  <xsl:apply-templates select='SYN'/>
  <xsl:apply-templates select='ANT'/>
  <xsl:apply-templates select='CF'/>
  <xsl:apply-templates select='COLLOC'/>
  <xsl:apply-templates select='CME'/>
  <xsl:apply-templates select='SE'/>
  <xsl:apply-templates select='PVL'/>
  <xsl:apply-templates select='ALT'/>
  <!-- end of links -->
  <xsl:text>
</xsl:text>
  <xsl:apply-templates select='DIALECTS'/>
  <xsl:apply-templates select='REGISTERS'/>
  <xsl:apply-templates select='POS'/>
  <xsl:apply-templates select='DOMAIN'/>
  <xsl:apply-templates select='SENSE'/>
</xsl:template>


<xsl:template match="HW">
    <xsl:apply-templates/>
    <xsl:if test='@HNUM'>
	<xsl:text> (</xsl:text>
	<xsl:value-of select="@HNUM"/>
	<xsl:text>)</xsl:text>
    </xsl:if>
</xsl:template>


<xsl:template match="ALT">
  <DL><DT><FONT COLOR="#E090B0"><B>Alternate Form: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="ANT">
  <DL><DT><FONT COLOR="#FF0000"><B>Opposite: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="CF">
  <DL><DT><FONT COLOR="#707070"><B>See also: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="CFI|SYNI|ANTI|SEI|CMEI|COLLI|XMEI|PVLI|ALTI">
<xsl:choose>
   <xsl:when test='@HENTRY="?"'>
     <xsl:apply-templates/>
   </xsl:when>
   <xsl:otherwise>
     <xsl:choose>
	<xsl:when test='@HNUM="#"'>
	<!-- still can't resolve exactly: choice list would be good! -->
	<xsl:apply-templates/>
	</xsl:when>
	<xsl:when test='@HNUM'>
	<A>
	<xsl:attribute name="HREF">@<xsl:value-of 
        select="@HENTRY"/>@<xsl:value-of select="@HNUM"/>.html</xsl:attribute>
	<xsl:apply-templates/>
	</A>
	</xsl:when>
	<xsl:otherwise>
	<A>
	<xsl:attribute name="HREF">@<xsl:value-of 
		select="@HENTRY"/>@.html</xsl:attribute>
	<xsl:apply-templates/>
	</A>
	</xsl:otherwise>
     </xsl:choose>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="CME">
  <DL><DT><FONT COLOR="#50E080"><B>Main Entry: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="COLLOC">
  <DL><DT><FONT COLOR="#FF00FF"><B>Used in talk with: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="CRITERION">
  <DT>
  <xsl:apply-templates/>
  </DT>
</xsl:template>


<xsl:template match="CT">
  <I><xsl:apply-templates/></I>
</xsl:template>


<xsl:template match="DEF">
  <P><B><I>Definition: </I></B>
  <xsl:apply-templates/>
  </P>
</xsl:template>


<!-- only show dialects for main entries -->
<xsl:template match="DIALECTS">
 <xsl:if test="../HW">
    <P><I>Dialects: </I>
    <xsl:apply-templates/>
    </P>
 </xsl:if>
</xsl:template>


<xsl:template match="DOMAIN">
  <P><I>Semantic domain:</I><xsl:text> </xsl:text>
  <xsl:for-each select="DMI">
    <xsl:value-of select="."/>
    <xsl:if test="not(position()=last())">:</xsl:if>
  </xsl:for-each>
  </P>
</xsl:template>


<xsl:template match="ET">
  <DD><FONT COLOR="#505050">
  <xsl:apply-templates/>
  </FONT></DD>
</xsl:template>


<xsl:template match="EXAMPLE">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="EXAMPLES">
  <DL>
  <xsl:apply-templates/>
  </DL>
</xsl:template>


<xsl:template match="GL">
  <H3><I>English: </I>
  <xsl:apply-templates/>
  </H3>
</xsl:template>
    

<xsl:template match="PDX">
  <DL>
  <xsl:apply-templates/>
  </DL>
</xsl:template>


<xsl:template match="POS">
  <P><I>Part of speech: </I>
  <xsl:apply-templates/>
  </P>
</xsl:template>


<xsl:template match="PVL">
  <DL><DT><FONT COLOR="#FF8040"><B>Preverbs: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<!-- only show dialects for main entries -->
<xsl:template match="REGISTERS">
 <xsl:if test="../HW">
    <P><I>Registers: </I>
    <xsl:apply-templates/>
    </P>
 </xsl:if>
</xsl:template>


<xsl:template match="SE">
  <DL><DT><FONT COLOR="#50E080"><B>Sub-entries: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="SENSE">
  <H3>Other sense <xsl:number/>:</H3>
  <xsl:apply-templates select='GL'/>
  <xsl:apply-templates select='DEF'/>
  <xsl:apply-templates select='EXAMPLES'/>
  <xsl:apply-templates select='PDX'/>
  <!-- links -->
  <xsl:apply-templates select='XME'/>
  <xsl:apply-templates select='SYN'/>
  <xsl:apply-templates select='ANT'/>
  <xsl:apply-templates select='CF'/>
  <xsl:apply-templates select='COLLOC'/>
  <xsl:apply-templates select='CME'/>
  <xsl:apply-templates select='SE'/>
  <xsl:apply-templates select='PVL'/>
  <xsl:apply-templates select='ALT'/>
  <!-- end of links -->
  <xsl:apply-templates select='DIALECTS'/>
  <xsl:apply-templates select='REGISTERS'/>
  <xsl:apply-templates select='POS'/>
  <xsl:apply-templates select='DOMAIN'/>
</xsl:template>


<!-- SRC's are deleted... -->   
<xsl:template match="SRC">
</xsl:template>


<xsl:template match="SYN">
  <DL><DT><FONT COLOR="#0000A0"><B>Same meaning: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>


<xsl:template match="WE">
<DT>
<xsl:choose>
   <xsl:when test='@TYPE'>
      <FONT COLOR="#400000">
      <xsl:apply-templates/>
      </FONT>
   </xsl:when>
   <xsl:otherwise>
      <xsl:apply-templates/>
   </xsl:otherwise>
</xsl:choose>
</DT>
</xsl:template>


<xsl:template match="XME">
  <DL><DT><FONT COLOR="#00FFFF"><B>Same as: </B></FONT></DT>
  <DD><xsl:apply-templates/></DD>
  </DL>
</xsl:template>

</xsl:stylesheet>
