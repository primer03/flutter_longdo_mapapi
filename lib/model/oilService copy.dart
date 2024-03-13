import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class OilService {
  List<Object?> District = [];
  Future<List<dynamic>> _fetchOil(String day, String month, String year) async {
    String url = 'https://orapiweb.pttor.com/oilservice/OilPrice.asmx';
    String soapRequest = '''
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ptt="http://www.pttor.com">
        <soap:Header/>
        <soap:Body>
          <ptt:GetOilPriceProvincial>
            <ptt:Language>th</ptt:Language>
            <ptt:DD>${day}</ptt:DD>
            <ptt:MM>${month}</ptt:MM>
            <ptt:YYYY>${year}</ptt:YYYY>
            <ptt:Province>Chon Buri</ptt:Province>
          </ptt:GetOilPriceProvincial>
        </soap:Body>
      </soap:Envelope>
  ''';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/soap+xml; charset=utf-8',
          'SOAPAction': 'http://www.pttor.com/GetOilPriceProvincial',
        },
        body: soapRequest,
      );

      if (response.statusCode == 200) {
        var document = xml.XmlDocument.parse(response.body);
        var resultElement =
            document.findAllElements('GetOilPriceProvincialResult').single;

        var fuelList = xml.XmlDocument.parse(resultElement.text)
            .findAllElements('FUEL_PROVINCIAL');
        List<Map<String, String>> fuelData = [];

        for (var fuel in fuelList) {
          var location = fuel.findElements('LOCATION').single.text;
          var priceDate = fuel.findElements('PRICE_DATE').single.text;
          var product = fuel.findElements('PRODUCT').single.text;
          var price = fuel.findElements('PRICE').single.text;

          fuelData.add({
            'Product': product,
            'Price': price,
            'Location': location,
            'PriceDate': priceDate,
          });
        }

        // print(resultElement);
        var locationData =
            fuelData.map((e) => e['Location']).toList().toSet().toList();

        var DatalfuelProvince = List.generate(
            locationData.length,
            (index) => {
                  'Location': locationData[index],
                  'Data': fuelData
                      .where((element) =>
                          element['Location'] == locationData[index])
                      .toList()
                });

        // DatalfuelProvince.forEach((element) {
        //   print("${element['Location']} \n");
        // });
        // District = DatalfuelProvince.map((e) => e['Location']).toList();
        return DatalfuelProvince;
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    return [];
  }

  Future<List<String>> getDistrict() async {
    var now = DateTime.now();
    var date = now.day.toString();
    var month = now.month.toString();
    var year = now.year.toString();
    var oil = await OilService()._fetchOil(date, month, year);
    var oilname = oil.map((e) => e['Location']).toList();
    var Distristr = [];
    District.forEach((element) {
      print(element);
    });
    return [];
  }

  Future<List<dynamic>> getSuggestions() async {
    var now = DateTime.now();
    var date = now.day.toString();
    var month = now.month.toString();
    var year = now.year.toString();
    var oil = await OilService()._fetchOil(date, month, year);
    var oilname = oil.map((e) => e['Product']).toList();
    return oil;
  }
}

void main(List<String> args) async {
  var Olix = new OilService();
  var oil = await Olix.getSuggestions();
  print(oil);
}
