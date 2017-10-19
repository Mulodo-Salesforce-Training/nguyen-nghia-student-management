/**
 * Created by remjx on 18-Oct-17.
 */
@isTest
private class SM_GMapAPIUtilTest {
	@isTest static void testGetAddressInfo() {
		Test.setMock(HttpCalloutMock.class, new SM_GlobalHttpMock());
		Test.startTest();
			SM_GMapAPIUtil.LatLng location = SM_GMapAPIUtil.getAddressInfo('Huỳnh Tấn Phát Quận 7 TPHCM Việt Nam');
		Test.stopTest();
		System.assertEquals(10.7143607, location.lat, 'Expect to be able to get latitude data from API ');
		System.assertEquals(106.7370375, location.lng, 'Expect to be able to get longitude data from API');
	}
}