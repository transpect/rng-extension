package io.transpect.calabash.extensions;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.ListIterator;
import java.util.Vector;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XQueryCompiler;
import net.sf.saxon.s9api.XQueryEvaluator;
import net.sf.saxon.s9api.XQueryExecutable;
import net.sf.saxon.s9api.XdmNode;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.thaiopensource.validate.SchemaReader;
import com.thaiopensource.validate.ValidationDriver;
import com.thaiopensource.validate.auto.AutoSchemaReader;

import com.xmlcalabash.core.XMLCalabash;
import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

@XMLCalabash(
        name = "letex:validate-with-rng",
        type = "{http://www.le-tex.de/namespace}validate-with-rng")

/**
 *
 * @author Lars Wittmar
 */
public class ValidateWithRelaxNG extends DefaultStep {
	private ReadablePipe source = null;
	private ReadablePipe schema = null;
	private WritablePipe result = null;
	private WritablePipe report = null;
	private URI docBaseURI = null;
	private ArrayList<String> myErrorFile = null;	
	private ArrayList<String> myErrorPath = null;
	private ArrayList<String> myErrorMessage = null;

	/** Creates a new instance of Delete */
	public ValidateWithRelaxNG(XProcRuntime runtime, XAtomicStep step) {
		super(runtime,step);
	}

	@Override
	public void setInput(String port, ReadablePipe pipe) {  
		if ("source".equals(port)) {
			source = pipe;
		} else if ("schema".equals(port)) {
			schema = pipe;
		}
	}

	@Override
	public void setOutput(String port, WritablePipe pipe) {
		if ("result".equals(port)) {
			result = pipe;
		} else if ("report".equals(port)) {
			report = pipe;
		}
	}

	@Override
	public void reset() {
		source.resetReader();
		result.resetWriter();
		report.resetWriter();
	}
	//source: 	xmlcalabash1/src/com/xmlcalabash/util/S9apiUtils.java 
	public static void serialize(XProcRuntime xproc, XdmNode node, Serializer serializer) throws SaxonApiException {
        Vector<XdmNode> nodes = new Vector<XdmNode> ();
        nodes.add(node);
        serialize(xproc, nodes, serializer);
    }

    public static void serialize(XProcRuntime xproc, Vector<XdmNode> nodes, Serializer serializer) throws SaxonApiException {
        Processor qtproc = xproc.getProcessor();
        XQueryCompiler xqcomp = qtproc.newXQueryCompiler();

        // Patch suggested by oXygen to avoid errors that result from attempting to serialize
        // a schema-valid document with a schema-naive query
        xqcomp.getUnderlyingStaticContext().setSchemaAware(
                xqcomp.getProcessor().getUnderlyingConfiguration().isLicensedFeature(
                        Configuration.LicenseFeature.ENTERPRISE_XQUERY));

        XQueryExecutable xqexec = xqcomp.compile(".");
        XQueryEvaluator xqeval = xqexec.load();
        xqeval.setDestination(serializer);
        for (XdmNode node : nodes) {
            xqeval.setContextItem(node);
            xqeval.run();
            // Even if we output an XML decl before the first node, we must not do it before any others!
            serializer.setOutputProperty(Serializer.Property.OMIT_XML_DECLARATION, "yes");
        }
    }
    
	// FIXME: THIS METHOD IS A GROTESQUE HACK!
    public static InputSource xdmToInputSource(XProcRuntime runtime, XdmNode node) throws SaxonApiException {
    	ByteArrayOutputStream out = new ByteArrayOutputStream();
        Serializer serializer = runtime.getProcessor().newSerializer();
        serializer.setOutputStream(out);
        serialize(runtime, node, serializer);
        InputSource isource = new InputSource(new ByteArrayInputStream(out.toByteArray()));
        isource.setSystemId(node.getBaseURI().toASCIIString());
        
        return isource;
    } 

	@Override
	public void run() throws SaxonApiException {    	 
		super.run();

		XdmNode doc = null;
		XdmNode schemaNode = null;
	  try {
			doc = source.read();
			schemaNode = schema.read();
			
			SchemaReader sr = new AutoSchemaReader();
			ValidationDriver driver = new ValidationDriver(sr);
			InputSource schemaInput = xdmToInputSource(runtime, schemaNode);
			InputSource sourceInput = xdmToInputSource(runtime, doc);
			
			//preparing the temp logfile
			File file = File.createTempFile("transpect-rng-", ".txt");
			FileWriter writer = new FileWriter(file);
			System.setProperty("LtxValidateTempFile", file.getAbsolutePath());
			writer.write(""); 
			writer.flush();
			writer.close();
			
			//validation
			driver.loadSchema(schemaInput);
			driver.validate(sourceInput);
			
			result.write(doc);
			
			//reading the result 
			FileReader fr = new FileReader(file);
			BufferedReader br = new BufferedReader(fr);

			String errorLine = null;
			myErrorFile = new ArrayList<String>();
			myErrorPath = new ArrayList<String>();
			myErrorMessage = new ArrayList<String>();

			while ((errorLine = br.readLine()) != null) {
				String[] splitResult = errorLine.split("file:|xpath:|error:");
				myErrorFile.add(splitResult[1].trim());
				myErrorPath.add(splitResult[2].trim());
				myErrorMessage.add(splitResult[3].trim());
			}    
			br.close();
			file.delete();
			System.clearProperty("LtxLtxValidateTempFile");			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (SAXException e) {	
			e.printStackTrace();
		} catch (IndexOutOfBoundsException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {
			e.printStackTrace();
		}

		ListIterator<String> it1 = myErrorFile.listIterator(0);
		ListIterator<String> it2 = myErrorPath.listIterator(0);
		ListIterator<String> it3 = myErrorMessage.listIterator(0);

		TreeWriter treeWriter = new TreeWriter(runtime);
		treeWriter.startDocument(docBaseURI);
		treeWriter.addStartElement(XProcConstants.c_errors);
		
		while( it1.hasNext() && it2.hasNext() && it3.hasNext())
		{
			treeWriter.startContent();
			treeWriter.addStartElement(XProcConstants.c_error);
			treeWriter.addAttribute(new QName("xpath"), it2.next());
			treeWriter.addText(it3.next());
			treeWriter.addEndElement();
		}
		treeWriter.addEndElement();
		treeWriter.endDocument();

		report.write(treeWriter.getResult());
	}    
}
