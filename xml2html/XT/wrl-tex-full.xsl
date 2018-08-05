<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/TR/WD-xsl"
  xmlns:html="http://www.w3.org/TR/REC-html40/"
  result-ns="">

<xsl:template match="/">
<xsl:text>\documentclass[10pt,twocolumn]{book}
\usepackage{wrldict}

\begin{document}
\maketitle
</xsl:text>
<xsl:apply-templates/>
<xsl:text>\end{document}
</xsl:text>
</xsl:template>

<xsl:template match="ALT">
  <xsl:text>\alt{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="ALTI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\altihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\alti{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="ANT">
  <xsl:text>\ant{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="ANTI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\antihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\anti{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="CF">
  <xsl:text>\cf{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="CFI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\cfihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\cfi{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="CM">
  <xsl:text>\cm{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="CME">
  <xsl:text>\cme{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="CMEI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\cmeihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\cmei{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="CMP">
  <xsl:text>\cmp{[</xsl:text><xsl:apply-templates/>
  <xsl:text>]}</xsl:text>
</xsl:template>


<xsl:template match="CRITERION">
  <xsl:text>\criterion{[</xsl:text><xsl:apply-templates/>
  <xsl:text>]}</xsl:text>
</xsl:template>


<xsl:template match="CSL">
  <xsl:text>\csl{[</xsl:text><xsl:apply-templates/>
  <xsl:text>]}</xsl:text>
</xsl:template>


<xsl:template match="CT">
  <xsl:text>\ct{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="DEF">
  <xsl:text>\def{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="DERIV">
  <xsl:text>\deriv{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="DIALECTS">
  <xsl:text>\dialects{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="DLI">
      <xsl:text>\dli{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
</xsl:template>


<!-- don't need to do anything for DICTIONARY -->


<xsl:template match="DOMAIN">
  <xsl:text>\domain{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="DMI">
  <xsl:text>\dmi{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="ENTRY">
  <!-- this does all - for other applications: subset! -->
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="ET">
  <xsl:text>\et{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="EXAMPLE">
  <xsl:text>\item </xsl:text><xsl:apply-templates/>
</xsl:template>

<xsl:template match="EXAMPLES">
  <xsl:text>\begin{examples}</xsl:text><xsl:apply-templates/>
  <xsl:text>\end{examples}</xsl:text>
</xsl:template>


<xsl:template match="GL">
  <xsl:text>\g{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="GLI">
  <xsl:text>\g{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="HW">
<xsl:choose>
   <xsl:when test='@TYPE'>
      <xsl:choose>
         <xsl:when test='@HNUM'>
	      <xsl:text>\hwsubhnum{</xsl:text>
	      <xsl:value-of select="@HNUM"/>
	      <xsl:text>}{</xsl:text>
	      <xsl:apply-templates/>
	      <xsl:text>}</xsl:text>
	 </xsl:when>
	 <xsl:otherwise>
	      <xsl:text>\hwsub{</xsl:text>
	      <xsl:apply-templates/>
	      <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
      <xsl:choose>
         <xsl:when test='@HNUM'>
	      <xsl:text>\hwhnum{</xsl:text>
	      <xsl:value-of select="@HNUM"/>
	      <xsl:text>}{</xsl:text>
	      <xsl:apply-templates/>
	      <xsl:text>}</xsl:text>
	 </xsl:when>
	 <xsl:otherwise>
	      <xsl:text>\hw{</xsl:text>
	      <xsl:apply-templates/>
	      <xsl:text>}</xsl:text>
	 </xsl:otherwise>
      </xsl:choose>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>
      

<xsl:template match="LAT">
  <xsl:text>\lat{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="LATIN">
  <xsl:text>\latin{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="PDX">
  <xsl:text>\begin{pdx}</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{pdx}</xsl:text>
</xsl:template>


<xsl:template match="POS">
  <xsl:text>\pos{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="PVL">
  <xsl:text>\pvl{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="PVLI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\pvlihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\pvli{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="REF">
  <xsl:text>\ref{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="REFA">
  <xsl:text>\refa{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="REGISTERS">
  <xsl:text>\registers{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="RGI">
      <xsl:text>\rgi{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="REM">
  <xsl:text>\rem{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="RUL">
  <xsl:text>\rul{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="SE">
  <xsl:text>\se{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="SEI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\seihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\sei{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="SENSE">
  <xsl:text>\begin{sense}</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\end{sense}</xsl:text>
</xsl:template>


<xsl:template match="SRC">
  <xsl:text>\src{[</xsl:text><xsl:apply-templates/>
  <xsl:text>]}</xsl:text>
</xsl:template>


<xsl:template match="SYN">
  <xsl:text>\syn{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="SYNI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\synihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\syni{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="WE">
<xsl:choose>
   <xsl:when test='@TYPE'>
      <xsl:text>\wed{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\we{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="XME">
  <xsl:text>\xme{</xsl:text><xsl:apply-templates/>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="XMEI">
<xsl:choose>
   <xsl:when test='@HNUM'>
      <xsl:text>\xmeihnum{</xsl:text>
      <xsl:value-of select="@HNUM"/>
      <xsl:text>}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>\xmei{</xsl:text><xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:otherwise>
</xsl:choose>
</xsl:template>




<!--
<xsl:if test="@exchange[.='nasdaq']">*</xsl:if>
<xsl:apply-templates select='POS'/>
-->

</xsl:stylesheet>

