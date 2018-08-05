<!--
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
  xmlns:html="http://www.w3.org/TR/REC-html40/"
  result-ns="html"
  default-space="strip"> -->

<xsl:template match='/'>
        <HTML><HEAD>
        <TITLE><xsl:process select='HW'/></TITLE>
       </HEAD><BODY TEXT="#000000" BGCOLOR="#FFFFFF" LINK="#006600" VLINK="#551A8B" ALINK="#FF0000">
		<xsl:process-children/>
	</BODY></HTML>
</xsl:template>

<xsl:template match='ENTRY'>
   <DL>
      <DT><a name=""></a><H1><B><xsl:process select='HW'/></B></H1></DT> 
          <xsl:process select='POS'/>
          <xsl:process select='DEF'/>
          <xsl:process select='GL'/>
          <xsl:process select='EXAMPLES'/>
          <xsl:process select='CF'/>
          <xsl:process select='SYN'/>
          <xsl:process select='ANT'/>
          <xsl:process select='COLLOC'/>
          <xsl:process select='XME'/>
          <xsl:process select='SENSE'/>
          </DL>
</xsl:template>

<!--
    <rule>
	<target-element type="HW"/>
	    <children/>
    </rule>

    <rule>
	<target-element type="POS"/>
	    <DD><I>(Part of speech: <children/> )</I></DD>
    </rule>
    
    <rule>
        <target-element type="DEF"/>
            <DD><B><U>Definition:</U> <children/></B></DD>
    </rule>

    <rule>
        <target-element type="GL"/>
            <DD><I><U>English:</U> <children/></I></DD>
    </rule>

    <rule>
	<target-element type="EXAMPLES"/>
	    <select-elements>
                <target-element type="EXAMPLE"/>
            </select-elements>    
    </rule>

    <rule>
        <target-element type="EXAMPLE"/>
        <DL>
            <select-elements>
                <target-element type="WE"/>
            </select-elements>   
            <select-elements>
                <target-element type="ET"/>
            </select-elements>   
        </DL>
    </rule>

    <rule>
        <target-element type="WE"/>
            <DT><B><FONT COLOR="#003300"><U>example:</U> <children/></FONT></B></DT>   
    </rule>

    <rule>
        <target-element type="ET"/>
            <DD><FONT COLOR="#333333"><B><U>translation:</U></B> <children/></FONT></DD>   
    </rule>

    <rule>
        <target-element type="CF"/>
        <DL>
            <DT><B>See Also:</B></DT>
            <DD><select-elements>
                    <target-element type="CFI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="CFI"/>
            <a href=""><children/></a>   
    </rule>

    <rule>
        <target-element type="SYN"/>
        <DL>
            <DT><FONT COLOR="#3333FF"><B>Similar Words:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="SYNI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="SYNI"/>
            <a href=""><children/></a>   
    </rule>

    <rule>
        <target-element type="ANT"/>
        <DL>
            <DT><FONT COLOR="#FF0000"><B>Opposite Words:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="ANTI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="ANTI"/>
            <a href=""><children/></a>   
    </rule>

    <rule>
        <target-element type="COLLOC"/>
        <DL>
            <DT><FONT COLOR="#FF00FF"><B>Used with the words:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="COLLI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="COLLI"/>
            <a href=""><children/></a>   
    </rule>

    <rule>
        <target-element type="XME"/>
        <DL>
            <DT><FONT COLOR="#999999"><B>See Also:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="XMEI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="XMEI"/>
            <a href=""><children/></a>   
    </rule>

    <rule>
        <target-element type="SUBENTRY"/>
            <DL>
                <DT><a name=""></a><B><select-elements><target-element type="SHW"/></select-elements></B></DT>
                
                <select-elements><target-element type="POS"/></select-elements>
                
                <select-elements>
                    <target-element type="DEF"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="GL"/>
                </select-elements>
            
                <select-elements>
                    <target-element type="EXAMPLES"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="CF"/>
                </select-elements>

                <select-elements>
                    <target-element type="SYN"/>
                </select-elements>

                <select-elements>
                    <target-element type="ANT"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="COLLOC"/>
                </select-elements>

                <select-elements>
                    <target-element type="XME"/>
                </select-elements>

            </DL>
    </rule>

    <rule>
        <target-element type="SENSE"/>
                <select-elements>
                    <target-element type="DEF"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="GL"/>
                </select-elements>
            
                <select-elements>
                    <target-element type="EXAMPLES"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="CF"/>
                </select-elements>

                <select-elements>
                    <target-element type="SYN"/>
                </select-elements>

                <select-elements>
                    <target-element type="ANT"/>
                </select-elements>
                
                <select-elements>
                    <target-element type="COLLOC"/>
                </select-elements>

                <select-elements>
                    <target-element type="XME"/>
                </select-elements>
    </rule>

</xsl:stylesheet>
-->

