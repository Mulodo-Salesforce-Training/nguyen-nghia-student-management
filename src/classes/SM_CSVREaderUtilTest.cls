/**
 * Created by nguyen.nghia@mulodo.com on 10/20/2017.
 */
@isTest
private class SM_CSVREaderUtilTest {
	@isTest static void testSplitCsvSimple(){
		String line = 'abc,efg';
		String[] splitted = new SM_CSVReaderUtil(line).readLine();
		System.assertEquals(2, splitted.size());

		System.assertEquals('efg', splitted[1]);
		System.assertEquals('abc', splitted[0]);
	}

	@isTest static void testSplitCsvEOL(){
		String line = 'abc,';
		String[] splitted = new SM_CSVReaderUtil(line).readLine();
		System.assertEquals(2, splitted.size());

		System.assertEquals('', splitted[1]);
		System.assertEquals('abc', splitted[0]);
	}

	@isTest static void testSplitCsvQuotedSimple(){
		String line = '"abc,def"';
		String[] splitted = new SM_CSVReaderUtil(line).readLine();
		System.assertEquals('abc,def', splitted[0]);
	}

	@isTest static void testSplitCsvQuoted(){
		String line = '"abc,def",gh"i,"jk""l",""';
		String[] splitted = new SM_CSVReaderUtil(line).readLine();
		System.assertEquals(4, splitted.size());
		System.assertEquals('gh"i', splitted[1]);
		System.assertEquals('abc,def', splitted[0]);
		System.assertEquals('jk"l', splitted[2]);
		System.assertEquals('', splitted[3]);
	}

	@isTest static void testSplitCsvQuotedWithNewLine(){
		String line = '"abc,def\nBoo\nBoo",Test';
		SM_CSVReaderUtil reader = new SM_CSVReaderUtil(line);
		String[] splitted = reader.readLine();
		System.assertEquals('abc,def\nBoo\nBoo', splitted[0]);
		System.assertEquals('Test', splitted[1]);
		System.assertEquals(null, reader.readLine());
	}
	static testmethod void testSplitCsvQuotedWithEOT(){
		String line = '"abc,def\nBoo';
		SM_CSVReaderUtil reader = new SM_CSVReaderUtil(line);
		String[] splitted = reader.readLine();
		System.assertEquals('abc,def\nBoo', splitted[0]);
		System.assertEquals(null, reader.readLine());
	}

	@isTest static void testTabDelim(){
		String line = 'abc\tdef';
		SM_CSVReaderUtil reader = new SM_CSVReaderUtil(line, '\t');
		String[] splitted = reader.readLine();
		System.assertEquals('abc', splitted[0]);
	}

	@isTest static void testEmptyStrings(){
		String line = ',,,,';
		SM_CSVReaderUtil reader = new SM_CSVReaderUtil(line);
		String[] splitted = reader.readLine();
		System.assertEquals(5, splitted.size());
		for(String s: splitted){
			System.assertEquals('', s);
		}
	}

	// make sure we still get a result even if the source is empty...
	@isTest static void testEmptyString(){
		String line = '';
		SM_CSVReaderUtil reader = new SM_CSVReaderUtil(line);
		String[] splitted = reader.readLine();
		System.assertEquals(1, splitted.size());
		System.assertEquals('', splitted[0]);
	}
}