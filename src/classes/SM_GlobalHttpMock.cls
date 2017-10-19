/**
 * Created by remjx on 18-Oct-17.
 */
@isTest
public class SM_GlobalHttpMock implements HttpCalloutMock{
	private static final String G_MAP_ROOT_ENDPOINT = 'https://maps.googleapis.com/maps/api/geocode/json';

//	MOCK JSON FORMAT IN NICELY FORMAT ===> REFERENCE IN TESTING LATER
//	{
//		"results": [
//			"address_components": [
//				{"long_name": "Huỳnh Tấn Phát", "short_name": "Huỳnh Tấn Phát", "types" : [ "route" ]},
//				{"long_name": "Hồ Chí Minh", "short_name": "Hồ Chí Minh", "types" : ["administrative_area_level_1", "political"]},
//				{"long_name": "Vietnam", "short_name": "VN", "types" : ["country", "political"]},
//			],
//			"formatted_address" : "Huỳnh Tấn Phát, Hồ Chí Minh, Vietnam",
//			"geometry": {
//				"location": {"lat": 10.7143607, "lng": 106.7198407},
//			}
//		],
//		"status": "OK"
//	}

	public static HttpResponse respond(HttpRequest req) {
		HttpResponse mockRes = new HttpResponse();
		String mockResBody;
		System.debug(req.getEndpoint());
		if ( req.getEndpoint().indexOf(G_MAP_ROOT_ENDPOINT) == 0 ) {
			mockResBody = '{"results":[{"address_components":[{"long_name":"Huỳnh Tấn Phát","short_name":"Huỳnh Tấn Phát","types":["route"]},{"long_name":"Hồ Chí Minh","short_name":"Hồ Chí Minh","types":["administrative_area_level_1","political"]},{"long_name":"Việt Nam","short_name":"VN","types":["country","political"]}],"formatted_address":"Huỳnh Tấn Phát, Hồ Chí Minh, Việt Nam","geometry":{"bounds":{"northeast":{"lat":10.756464,"lng":106.7677553},"southwest":{"lat":10.6734093,"lng":106.7198407}},"location":{"lat":10.7143607,"lng":106.7370375},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":10.756464,"lng":106.7677553},"southwest":{"lat":10.6734093,"lng":106.7198407}}},"place_id":"ChIJ14Jfz4cldTERWY0hfNDowsM","types":["route"]}],"status":"OK"}';
			mockRes.setHeader('Content-Type', 'application/json');
			mockRes.setBody(mockResBody);
			mockRes.setStatusCode(200); // OK STATUS CODE
		} else {
			mockRes.setHeader('Content-Type', 'text/plain');
			mockRes.setBody('Http Mock Work!');
			mockRes.setStatusCode(200); // ok
		}

		// default mockRes;

		return mockRes;
	}
}