<xsl>

	<rule>
		<root/>

		<HTML>
			<BODY font-family="verdana,arial,helvetica" background-color="teal" color="white">
				<DIV font-size="24pt" text-align="center">
					Daily Menu
				</DIV>
				<DIV font-style="italic" text-align="center" margin-bottom="1em">
					Served from 5AM to noon.
				</DIV>

				<TABLE background-color="#DDDDDD" color="black">
					<THEAD background-color="#333333" color="#DDDDDD">
						<TR>
							<TD></TD>
							<TD>
								<DIV font-weight="bold" font-size="10pt">Item</DIV>
							</TD>
							<TD>
								<DIV font-weight="bold" font-size="10pt">Price</DIV>
							</TD>
							<TD>
								<DIV font-weight="bold" font-size="10pt">Description</DIV>
							</TD>
							<TD>
								<DIV font-weight="bold" font-size="10pt">Calories</DIV>
							</TD>
							<TD NOWRAP="true">
								<DIV font-weight="bold" font-size="10pt">%RDA*</DIV>
							</TD>
						</TR>
					</THEAD>
					<TBODY>
						<children/>
					</TBODY>
				</TABLE>
				<DIV font-size="9pt" text-align="right" margin-bottom="1em">
					* Recommended Daily Allowance for 3000 calories/day diet.
				</DIV>
			</BODY>
		</HTML>
	</rule>

	<rule>
		<target-element type="food"/>
		<TR>
			<TD VALIGN="top">
				<DIV font-size="10pt" font-weight="bold"><eval>formatNumber(childNumber(this), "1")</eval>)</DIV>
			</TD>
			<children/>
		</TR>
	</rule>

    <rule>
	    <target-element type="name"/>
	    <TD VALIGN="top">
		    <DIV font-size="10pt" font-weight="bold"><children/></DIV>
	    </TD>
    </rule>

    <rule>
	    <target-element type="price"/>
	    <TD VALIGN="top">
		    <DIV font-size="10pt" color="maroon" font-weight="bold"><children/></DIV>
	    </TD>
    </rule>

    <rule>
	    <target-element type="description"/>
	    <TD VALIGN="top">
		    <DIV font-size="10pt"><children/></DIV>
	    </TD>
    </rule>

	<rule>
		<target-element type="calories"/>
		<TD VALIGN="top">
			<DIV font-size="10pt" text-align="right"><children/></DIV>
		</TD>
		<TD VALIGN="top">
			<DIV font-size="10pt" text-align="right"><eval>formatNumber(text*100/3000, "1") + "%"</eval></DIV>
		</TD>
	</rule>

</xsl>