/**
 * Created by remjx on 18-Oct-17.
 */

public class SM_StudentProfileCE {
	// controller extension manipulate Standard Controller
	public String studentId {get;set;}
	public Student__c targetStudent {get;set;}
	public SM_StudentProfileCE(ApexPages.StandardController stdCtrl) {
		studentId = ApexPages.currentPage().getParameters().get('id');
		targetStudent = [SELECT Street__c, State_Province__c, Country__c, Map_Location__c, Map_Location__Longitude__s, Map_Location__Latitude__s FROM Student__c WHERE Id =: studentId];
	}

	public String getStudentFullAdd() {
		//FULL ADDRESS = STREET__c + STATE_PROVINCE__c + COUNTRY__C
		String fullAddress = '';
		if (targetStudent.Street__c != null) { fullAddress += targetStudent.Street__c; }
		if (targetStudent.State_Province__c != null) { fullAddress += (' ' + targetStudent.State_Province__c); }
		if (targetStudent.Country__c != null) { fullAddress += (' ' + targetStudent.Country__c); }
		return fullAddress;
	}

	public String getStudentLocation() {
		if (targetStudent.Map_Location__Longitude__s != null && targetStudent.Map_Location__Latitude__s != null) {
			return JSON.serialize(targetStudent.Map_Location__c);
		} else {
			return JSON.serialize(SM_GMapAPIUtil.getAddressInfo(getStudentFullAdd()));
		}

	}

	// DML not accept on constructor ===> move DML to other method here
	public void initStudentLocation() {
		if (targetStudent.Map_Location__Longitude__s == null || targetStudent.Map_Location__Latitude__s == null) {
			String studentAddress = getStudentFullAdd();
			if (studentAddress != null) {
				SM_GMapAPIUtil.LatLng geo = SM_GMapAPIUtil.getAddressInfo(studentAddress);
				System.debug(geo);
				if (geo != null) {
					targetStudent.Map_Location__Latitude__s = geo.lat;
					targetStudent.Map_Location__Longitude__s = geo.lng;
					update targetStudent;
				}
			}
		}
	}



}