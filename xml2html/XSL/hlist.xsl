<xsl>

	<define-script><![CDATA[
		var quote="'";
		function depth(e) {
			var i=0;
			while (e.parent) {
				e = e.parent;
				i++;
			}
			return i-1;
		}

		function uniqueID(e) {
			return e.tagName + formatNumberList(path(e), "1", "_");
		}

		function hasChildren(e) {
			return (e.children.length != 0);
		}

		function initialState(e) {
			if (e.children.length == 0)
				return ('none');

			if (depth(e)>1)
				return ('plus');
			else
				return ('minus');
		}

	]]></define-script>

	<rule>
		<root/>
		<HTML>
			<HEAD>
				<SCRIPT><![CDATA[
					var altState = false;
					function keypressed() {
						if (window.event.keyCode == 18)
							altState = true;
					}
					
					function keyreleased() {
						if (window.event.keyCode == 18)
							altState = false;
					}
					
					function hilight(id, on) {
						var theItem = document.all.item(id);
						if (theItem.className != "none")
							theItem.children.item(0).children.item(0).style.backgroundColor = on ? "yellow" : "white";
					}

					function setState(state, theItem) {
						if (state == "minus") {
							theItem.children.item(1).style.display = "block";
							theItem.children.item(0).children.item(0).src = "minus.gif";
						} else if (state == "plus") {
							theItem.children.item(1).style.display = "none";
							theItem.children.item(0).children.item(0).src = "plus.gif";
						}
						theItem.className = state;
					}

					function show(id) {
						var theItem = document.all.item(id);
						if (theItem.className == "plus") {
							setState("minus", theItem);
						} else if (theItem.className == "minus") {
							if (altState) {
								var theContents = theItem.children.item(1);
								var allClosed = true;
								var i;
								for (i = 0; i < theContents.children.length; i++) {
									var aChild = theContents.children.item(i);
									if (aChild.className == "minus") {
										setState("plus", aChild);
										allClosed = false;
									}
								}
								if (allClosed) {
									for (i = 0; i < theContents.children.length; i++) {
										var aChild = theContents.children.item(i);
										if (aChild.className == "plus")
											setState ("minus", aChild);
									}
								}
							} else {
								setState("plus", theItem);
							}
						}
					}

					function allLevels(state) {
                        var i, theItem, currentState, desiredState;
                        
						if (state == "expand") {
                            currentState = "plus";
                            desiredState = "minus";
                        } else {
                            currentState = "minus";
                            desiredState = "plus";
                        }

						var allDivs = document.all.tags("DIV");
						for (i=0; i < allDivs.length; i++) {
							theItem = allDivs.item(i);
							if (theItem.className == currentState) {
								setState(desiredState, theItem);
							}
						}
					}
				]]></SCRIPT>
			</HEAD>
			<BODY	font-size="10pt"
					font-family="Verdana"
					onkeydown="keypressed();"
					onkeyup="keyreleased();">
				<DIV margin-bottom="4px" font-size="18pt" font-weight="bold">
					XML Data Browser
				</DIV>
				<DIV font-size="9pt" font-style="italic">
					Instructions:
					<IMG src="plus.gif" hspace="4"/>Click to show children.
					<IMG src="minus.gif" hspace="4"/>Click to hide children. Alt-click to hide or show all children.
					<IMG src="none.gif" hspace="4"/>No children.
				</DIV>
				<DIV font-size="9pt" font-style="italic" margin-bottom=".5em">
					Click here to
					<SPAN	ID="expandAll" CLASS="global-control"
							text-decoration="underline"
							onMouseOver="style.backgroundColor = 'yellow'"
							onMouseOut="style.backgroundColor = ''"
							onClick="allLevels('expand')">Expand All Elements</SPAN>, or to
					<SPAN ID="collapseAll" CLASS="global-control"
							text-decoration="underline"
							onMouseOver="style.backgroundColor = 'yellow'"
							onMouseOut="style.backgroundColor = ''"
							onClick="allLevels('collapse')">Collapse All Elements</SPAN>.
					<HR/>
				</DIV>
				<DIV	ID="=uniqueID(this)"
						class="=initialState(this)"
						margin-left="16px">
					<DIV	text-indent="-16px"
							font-weight="bold"
							onMouseOver="='hilight(' + quote + uniqueID(this) + quote + ',true)'"
							onMouseOut="='hilight(' + quote + uniqueID(this) + quote + ',false)'"
							onClick="= 'show(' + quote + uniqueID(this) + quote + ')'">
						<IMG src="=initialState(this) + '.gif'" background-color="white"/>
						&lt;<eval>tagName</eval>&gt;
					</DIV>
					<DIV>
						<children/>
					</DIV>
				</DIV>
			</BODY>
		</HTML>
	</rule>

	<rule>
		<target-element/>
		<DIV	ID="=uniqueID(this)"
				class="=initialState(this)"
				margin-left="16px">
			<DIV	text-indent="-16px"
					font-weight="bold"
					onMouseOver="='hilight(' + quote + uniqueID(this) + quote + ',true)'"
					onMouseOut="='hilight(' + quote + uniqueID(this) + quote + ',false)'"
					onClick="= 'show(' + quote + uniqueID(this) + quote + ')'">
				<IMG src="=initialState(this) + '.gif'" background-color="white"/>
				&lt;<eval>tagName</eval>&gt;
			</DIV>
			<DIV STYLE="='display:' + (depth(this)>1 ? 'none' : 'block')">
				<children/>
			</DIV>
		</DIV>
	</rule>

</xsl>