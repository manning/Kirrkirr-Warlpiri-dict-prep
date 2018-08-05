<xsl>

    <rule>
	    <root/>
	    <HTML>
			<BODY font-family="Arial, helvetica, sans-serif" font-size="12pt"
					background-color="#EEEEEE">
				<children/>
			</BODY>
		</HTML>
    </rule>


    <rule>
	    <target-element type="food"/>
	    <DIV background-color="teal" color="white" padding="4px">
			<select-elements>
				<target-element type="name"/>
			</select-elements>
			-
			<select-elements>
				<target-element type="price"/>
			</select-elements>
		</DIV>
	    <DIV margin-left="20px" margin-bottom="1em" font-size="10pt">
			<select-elements>
				<target-element type="description"/>
			</select-elements>
			<select-elements>
				<target-element type="calories"/>
			</select-elements>
		</DIV>
    </rule>

    <rule>
	    <target-element type="name"/>
		<SPAN font-weight="bold" color="white">
			<children/>
		</SPAN>
    </rule>

    <rule>
	    <target-element type="price"/>
	    <target-element type="description"/>
		<children/>
    </rule>

    <rule>
	    <target-element type="calories"/>
		<SPAN font-style="italic">
			(<children/> calories per serving)
		</SPAN>
    </rule>

</xsl>