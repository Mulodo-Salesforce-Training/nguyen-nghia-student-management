/**
 * Created by remjx on 18-Oct-17.
 */
public with sharing class SM_GMapAPIUtil {
	private static final String GMAP_API_KEY = [SELECT apikey__c FROM External_App_Setting__mdt WHERE label = 'gMapKey'].apikey__c; // gMap API Key
	private static final String GEOCODING_URI_BASE = 'https://maps.googleapis.com/maps/api/geocode/json';
	private static final String GEOCODING_URI_FORMAT =  GEOCODING_URI_BASE + '?address={0}&key={1}'; // 0: address url encoded, 1: api key
	//	URL FORMAT https://maps.googleapis.com/maps/api/geocode/json?address={ADDRESS_URL_ENCODED}&key={YOUR_API_KEY}
	public static LatLng getAddressInfo(String address) {
		LatLng geo;
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setTimeout(10000); // millisec
		String encodedAddress = EncodingUtil.urlEncode(address, 'UTF-8'); // encoding address
		req.setEndpoint(String.format(GEOCODING_URI_FORMAT, new List<String> {encodedAddress, GMAP_API_KEY}));
		try {
			HttpResponse res = http.send(req);
			GResponse googleRes = (GResponse) JSON.deserialize(res.getBody(), SM_GMapAPIUtil.GResponse.class);
			System.debug(googleRes);
			if (googleRes.status == 'OK') {
				geo = googleRes.results[0].geometry.location;
			}
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		return geo;
	}

	public class GResponse{
		public String status;
		public GComponents[] results;
	}
	public class GComponents{
		public String formatted_address;
		public GGeometry geometry;
	}
	public class GGeometry {
		public LatLng location;
	}
	public class LatLng{
		public Double lat, lng;
	}

}