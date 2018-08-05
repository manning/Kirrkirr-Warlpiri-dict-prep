<xsl>

<!-- this style sheet was used pre-thesis deadline ie. clickText version
-->

    <define-script><![CDATA[
        function tellMe(e) {
            if(e.getAttribute("HNUM")) 
                return e.getAttribute("HNUM");
            else 
                return "";
        }
        ]]>
    </define-script>

    <rule>
	<root/>
        <HTML><HEAD>
                <TITLE><select-elements><target-element type="HW"/></select-elements></TITLE>
              </HEAD><BODY TEXT="#000000" BGCOLOR="#ECFFEC" LINK="#6E6761" VLINK="#551A8B" ALINK="#FF0000">
	    <children/>
	</BODY></HTML>
    </rule>

    <rule>
        
        <target-element type="ENTRY"/>
            <DL>
                <DT><a name=""><H1><B><select-elements><target-element type="HW"/></select-elements></B></H1></a></DT>
                
                <select-elements>
                    <target-element type="GL"/>
                </select-elements>
            
                
                <select-elements>
                    <target-element type="DEF"/>
                </select-elements>
                
                <select-elements><target-element type="POS"/></select-elements>
                
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
                
                <select-elements>
                    <target-element type="PVL"/>
                </select-elements>

                <select-elements>
                    <target-element type="SENSE"/>
                </select-elements>

                <select-elements>
                    <target-element type="SUBENTRY"/>
                </select-elements>

                <select-elements>
                    <target-element type="PDX"/>
                </select-elements>

            </DL>


    </rule>

<!-- this should work, for some reason present version of msxsl ignores the has-value tag 
     (not even my function 'tellMe' will work - above)
       - maybe it would if I findout how to do exception handling in jscript - then just catch the exception
          if you try to getAttribute when theres none there
    <rule>
        <element type="HW"/>
        <target-element type="HW"/>
        <attribute name="HNUM" has-value="no"/>
            <children/> 
    </rule>
    
    <rule>
        <element type="HW"/>
        <target-element type="HW"/>
        <attribute name="HNUM" has-value="yes"/>
                <children/> (<eval>tellMe(this)</eval>)
    </rule>


       - instead I have to use the dummy tag <NUM num='$HNUM'/> which doesn't cause fatal errors as it allows you
       to call getAttribute to retieve an attribute. Allows split_target to convert it to a formatted value 
       or delete it.
       - NB it will cause warnings though, but these can be ignored because the html file is still created.
-->

    <rule>
        <target-element type="HW"/>
        <attribute name="HNUM" has-value="yes"/>
            <children/><NUM num='=getAttribute("HNUM")'/>
    </rule>


    <rule>
	<target-element type="POS"/>
	    <DD><I>(Part of speech:&nbsp;<children/>&nbsp;)</I></DD>
    </rule>
    
    <rule>
        <target-element type="DEF"/>
            <DD><B><I>Definition:</I></B>&nbsp;<children/></DD>
    </rule>

<!--
    <rule>
        <target-element type="GL"/>
        <DL>
            <DT><I>English:</I></DT>
            <DD><select-elements>
                    <target-element type="FL"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>
-->

    <rule>
        <target-element type="GL"/>
            <DD><I>English:</I>&nbsp;<children/></DD>
    </rule>
    
    <rule>
	<target-element type="EXAMPLES"/>
	    <select-elements>
                <target-element type="EXAMPLE"/>
            </select-elements>    
    </rule>

    <rule>
        <target-element type="EXAMPLE"/>
            <select-elements>
                <target-element type="WE"/>
            </select-elements>   
            <select-elements>
                <target-element type="ET"/>
            </select-elements>   
    </rule>

    <rule>
        <target-element type="WE"/>
            <DD><FONT COLOR="#000000"><B>example:</B>&nbsp;<children/></FONT></DD>   
    </rule>

    <rule>
        <target-element type="ET"/>
            <DD><FONT COLOR="#999999"><B>translation:</B>&nbsp;<children/></FONT></DD>   
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
        <target-element type="SYN"/>
        <DL>
            <DT><FONT COLOR="#000099"><B>Similar Words:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="SYNI"/>
                </select-elements>   
            </DD>
        </DL>
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
        <target-element type="PVL"/>
        <DL>
            <DT><FONT COLOR="#FF8040"><B>Pre Verb list:</B></FONT></DT>
            <DD><select-elements>
                    <target-element type="PVLI"/>
                </select-elements>   
            </DD>
        </DL>
    </rule>

    <rule>
        <target-element type="PDX"/>
        <DL>
            <DT><FONT COLOR="#663366"><B>Examples: <select-elements><target-element type="CRITERION"/>                </select-elements></B></FONT></DT>
            <DD>
                <select-elements>
                    <target-element type="DEF"/>
                </select-elements>
                <select-elements>
                   <target-element type="EXAMPLES"/>
                </select-elements>
                <select-elements>
                    <target-element type="GL"/>
                </select-elements>
                
            </DD>
        </DL>
    </rule>
    
    <rule>
        <target-element type="CRITERION"/>
            <I><children/></I>
    </rule>

    <rule>
        <target-element type="CFI" position="first-of-type"/>
        <target-element type="SYNI" position="first-of-type"/>
        <target-element type="ANTI" position="first-of-type"/>
        <target-element type="COLLI" position="first-of-type"/>
        <target-element type="XMEI" position="first-of-type"/>
        <target-element type="PVLI" position="first-of-type"/>
            <a href=""><children/></a>,&nbsp;&nbsp;&nbsp; 
    </rule>
    
    <rule>
        <target-element type="CFI"/>
        <target-element type="SYNI"/>
        <target-element type="ANTI"/>
        <target-element type="COLLI"/>
        <target-element type="XMEI"/>
        <target-element type="PVLI"/>
            <a href=""><children/></a>,&nbsp;&nbsp;&nbsp;
    </rule>


    <rule>
        <target-element type="CFI" position="last-of-type"/>
        <target-element type="SYNI" position="last-of-type"/>
        <target-element type="ANTI" position="last-of-type"/>
        <target-element type="COLLI" position="last-of-type"/>
        <target-element type="XMEI" position="last-of-type"/>
        <target-element type="PVLI" position="last-of-type"/>
            <a href=""><children/></a>&nbsp;&nbsp;&nbsp;
    </rule>

    <rule>
        <target-element type="SUBENTRY"/>
            <DL>
                <DT><B><I>Subentry:</I>&nbsp;<select-elements><target-element type="HW"/></select-elements></B></DT>
                
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

                <select-elements>
                    <target-element type="PVL"/>
                </select-elements>

                <select-elements>
                    <target-element type="PDX"/>
                </select-elements>

            </DL>
    </rule>

    <rule>
        <target-element type="SENSE"/>
                <DD><B><I>Alternate Sense:</I></B></DD>
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
                
                <select-elements>
                    <target-element type="PVL"/>
                </select-elements>

                <select-elements>
                    <target-element type="PDX"/>
                </select-elements>

    </rule>
</xsl>