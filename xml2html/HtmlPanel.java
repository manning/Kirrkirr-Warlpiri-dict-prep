/* HtmlPanel.java kjansz
* Display the Html dictionary and be able to scroll to hyperlink
* targets if specifed as a decimal approximate of the target relative to the
* entire document. 
* ie. instead of #_midway_  to go to a point half way in the page, you
* will need to use #0.5 which will scroll to the apporximate position
*
* Adapted from the HtmlPanel.java class from the SwingSet example in the Swing 1.03 release
* Copyright (c) 1997 Sun Microsystems, Inc. All Rights Reserved.
*
*/

import com.sun.java.swing.*;
import com.sun.java.swing.event.*;
import com.sun.java.swing.border.*;
import com.sun.java.swing.text.*;
import com.sun.java.accessibility.*;

import java.awt.*;
import java.awt.event.*;
import java.net.URL;
import java.net.MalformedURLException;
import java.io.IOException;

import COM.stevesoft.pat.Regex;

public class HtmlPanel extends JPanel implements HyperlinkListener {
    JEditorPane html;
    JScrollPane scroller;
    JViewport vp;
    String current;
    
    public HtmlPanel(String file) {
	// setBackground(Color.white);
	setBorder(new EmptyBorder(10,10,10,10));
        setLayout(new BorderLayout());
	getAccessibleContext().setAccessibleName("HTML panel");
	getAccessibleContext().setAccessibleDescription("A panel for viewing HTML documents, and following their links");
	
	try {
	    URL url = new URL(file);
            current = file;
	    html = new JEditorPane(url);
	    html.setEditable(false);
	    html.addHyperlinkListener(this);
	    scroller = new JScrollPane();
	    scroller.setBorder(new SoftBevelBorder(BevelBorder.LOWERED));
	    vp = scroller.getViewport();
	    vp.add(html);
	    vp.setBackingStoreEnabled(true);
	    add(scroller, BorderLayout.CENTER);
	} catch (MalformedURLException e) {
	    System.out.println("Malformed URL: " + e);
	} catch (IOException e) {
	    System.out.println("IOException: " + e);
	}
	
    }

    Dimension preferredSize = new Dimension(500, 700);
    Dimension minimumSize = new Dimension(500, 700);

    public Dimension getMinimumSize() {
        return minimumSize;
    }

    public Dimension getPreferredSize() {
        return preferredSize;
    }

    /**
     * Notification of a change relative to a 
     * hyperlink.
     */
    public void hyperlinkUpdate(HyperlinkEvent e) {
        Regex regex = Regex.perlCode("s/[#](.+?)$//");        
        try {
            if(regex.search(e.getURL().toString())) {
                String target = regex.stringMatched(1);
                String file   = regex.replaceAll(e.getURL().toString());
                file= file.trim();

                Double t = new Double(target);
                Dimension d = vp.getViewSize();
                int height = (new Double(t.doubleValue()*d.height)).intValue();
                
                System.out.println(" scroll to: "+height+" of "+d.height+" in "+file+" (target: "+target+")");
                
                //if(current.equals(file)) {
                //    vp.setViewPosition(new Point(0, height));
                //}
                //else {
                    linkActivated(e.getURL(), height);
                //}
            }
        }
        catch(NumberFormatException nfe) {
            if (e.getEventType() == HyperlinkEvent.EventType.ACTIVATED) {
                System.out.println(e.getURL());
                linkActivated(e.getURL(), 0);
            }
        }
    }

    /**
     * Follows the reference in an
     * link.  The given url is the requested reference.
     * By default this calls <a href="#setPage">setPage</a>,
     * and if an exception is thrown the original previous
     * document is restored and a beep sounded.  If an 
     * attempt was made to follow a link, but it represented
     * a malformed url, this method will be called with a
     * null argument.
     *
     * @param u the URL to follow
     */
    protected void linkActivated(URL u, int height) {
	Cursor c = html.getCursor();
	Cursor waitCursor = Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR);
	html.setCursor(waitCursor);
	SwingUtilities.invokeLater(new PageLoader(u, c, height));
    }

    /**
     * temporary class that loads synchronously (although
     * later than the request so that a cursor change
     * can be done).
     */
    class PageLoader implements Runnable {
	
	PageLoader(URL u, Cursor c, int h) {
	    url = u;
	    cursor = c;
            height = h;
	}

        public void run() {
	    if (url == null) {
		// restore the original cursor
		html.setCursor(cursor);

		// PENDING(prinz) remove this hack when 
		// automatic validation is activated.
		Container parent = html.getParent();
		parent.repaint();
	    } else {
		Document doc = html.getDocument();
		try {
		    html.setPage(url);
                    vp.setViewPosition(new Point(0, height));
		} catch (IOException ioe) {
		    html.setDocument(doc);
		    getToolkit().beep();
		} finally {
		    // schedule the cursor to revert after
		    // the paint has happended.
		    url = null;
		    SwingUtilities.invokeLater(this);
		}
	    }
	}

	URL url;
	Cursor cursor;
        int height;
    }

    static String makeAbsoluteURL (String url) throws MalformedURLException
    {
        URL baseURL=null;

        try {
            URL test = new URL(url);
        }
        catch (MalformedURLException e) {
        
            String currentDirectory = System.getProperty("user.dir");

            String fileSep = System.getProperty("file.separator");
            String file = currentDirectory.replace(fileSep.charAt(0), '/') + '/';
            if (file.charAt(0) != '/') {
                file = "/" + file;
            }
            baseURL = new URL("file", null, file);
        }
        return new URL(baseURL,url).toString();     
    }

    static public void handleException(Throwable exception) {
        System.err.println("--------- UNCAUGHT EXCEPTION ---------");
        exception.printStackTrace(System.out);
    }


    public static void main(String argv[]) {
        try {
            //newline = System.getProperty("line.separator");
            WindowListener winlin = new WindowAdapter() {
                    public void windowClosing(WindowEvent e) { System.exit(0); }
            };

            JFrame window = new JFrame("HTML viewer");
            window.addWindowListener(winlin);
            HtmlPanel hP = new HtmlPanel(makeAbsoluteURL(argv[0]));
            window.getContentPane().add("Center", hP);
            window.setBounds(0, 0, 1000, 1000);

            window.pack();
            window.setVisible(true);
        } 
        catch (Throwable exception) {
            System.err.println("Exception occurred in main() of java.lang.Object");
            System.err.println(exception);
            handleException(exception);
        }
    }
}
