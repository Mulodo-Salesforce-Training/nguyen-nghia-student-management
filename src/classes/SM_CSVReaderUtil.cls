/**
 * Created by nguyen.nghia@mulodo.com on 10/20/2017.
 */
public class SM_CSVReaderUtil {
	//  Csv Reader -- courtesy of <a target="_blank" href="http://blog.nicocrm.com/2011/03/06/parse-csv-file-in-salesforce-apex/" rel="nofollow">http://blog.nicocrm.com/2011/03/06/parse-csv-file-in-salesforce-apex/</a>
	//
	//  Usage: Call Constructor with entire Csv Stream then call readLine to get array of string tokens for each line; first row will be header row. readLine returns null at end of stream
	private String     delim = ',';

	private String[]   buffer;              // the input data for entire CSV file

	//  ------------------------------
	//  Constructors
	//  ------------------------------
	public SM_CSVReaderUtil(String data){
		this.buffer = (data == null ? new List<String>() : data.split('\n'));
	}

	public SM_CSVReaderUtil(String data, String delim){
		this.buffer = (data == null ? new List<String>() : data.split('\n'));
		this.delim = delim;
	}

	//  -------------------------------
	//  readLine - returns array of csv tokens as strings; reads through buffer, removing from buffer as each line is located in toto. Return null if end of stream.
	//  -------------------------------
	public String[] readLine(){
		if(this.buffer.size() == 0) return null;
		String     line     = this.buffer.remove(0);    // grab first part of stream up to newline; remove from buffer
		String[]   parts     = new String[] {};        // result list of tokens for one line
		while(line != ''){
			Integer next = 0;
			if(line.startsWith('"')){
				line = line.substring(1); // strip initial "
				Integer quoteIndex = findQuote(line, 0);    // Look for closing " on same line
				while(quoteIndex == -1){            //  not found, we must have a newline within a quoted token
					if(buffer.size() == 0){
						// EOT!
						quoteIndex = line.length();
					}
					else {
						// grab the next line and look to see if closing " can be found
						Integer skip = line.length();
						line += '\n' + this.buffer.remove(0);
						quoteIndex = findQuote(line, skip);
					}
				}
				// we have a quoted token, advance to comma
				next = quoteIndex + 1;
				parts.add(line.substring(0, quoteIndex).replace('""', '"'));
			}
			else {    // non-quoted token, token end is at delim
				next = line.indexOf(this.delim, next);
				if(next == -1)
					next = line.length();
				// NB in Substring, "endindex" is the index of the character AFTER the last index to get
				parts.add(line.substring(0, next));
			}
			if(next == line.length() - 1)
				// case of a terminating comma.
				parts.add('');
			line = next < line.length() ? line.substring(next+1) : '';
		}
		if(parts.size() == 0)
			// empty string - we still want to return something...
			parts.add('');
		return parts;
	}

	static private Pattern quotePattern = Pattern.compile('(?<!")"(?!")');

	//  -------------------------------------------------
	//  Helper: findQuote - find next quote " in line
	private Integer findQuote(String line, Integer skip){
		Matcher m = quotePattern.matcher(line);
		m.region(skip, m.regionEnd());
		if(!m.find())
			return -1;
		return m.start();
	}
}