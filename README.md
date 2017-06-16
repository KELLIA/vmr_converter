# vmr-converter
small conversion script to convert xml data from the vmr to CopticScriptorium / NLP Format

## before you start
install required python packages:
- pip install flask
- pip install flask_cors
- pip install requests

## running the converter
The converter is designed as simple web-app. To run it you need to start it as server:
- go to the folder of the vmr-converter
- run app.py by typing "python app.py" to your console
- check IP and port. By default it is running on localhost, Port 5000
- type <IP:PORT> as URL to your browser (e.g. localhost:5000)

## folders and files
- "vmr_converter": Home folder of vmr_converter
- "vmr_converter/app.py": the main-file routing the application
- "vmr_converter/converter.py": application logic
- "vmr_converter/templates/": html-files used for templating the webpage
- "vmr_converter/saxon/": home of the saxon9 Home-edition JAR File
- "vmr_converter/xslt/": home of xslt stylesheets
- "vmr_converter/xslt/cs_nlp.xsl": coptic scriptorium stylesheet

## use
- starting the server as mentioned above and go to the address the server is running on
- retrieve a converted document from vmr: &gt;server-IP&lt;:&gt;PORT&lt;/converter/vmr/docID=&gt;vmr-docID&lt;
- retrieve a converted document from vmr by page or page-range: &gt;server-IP&lt;:&gt;PORT&lt;/converter/vmr/?docID=&gt;vmr-docID&lt;&pageID=&gt;page&lt;
- when running on localhost e.g.: localhost:5000/converter/vmr/?docID=690003&pageID=0-400