import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class OilService {
  Future<List<dynamic>> _fetchOil(String day, String month, String year) async {
    String url = 'https://orapiweb.pttor.com/oilservice/OilPrice.asmx';
    String soapRequest = '''
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ptt="http://www.pttor.com">
        <soap:Header/>
        <soap:Body>
          <ptt:GetOilPrice>
            <ptt:Language>en</ptt:Language>
            <ptt:DD>${day}</ptt:DD>
            <ptt:MM>${month}</ptt:MM>
            <ptt:YYYY>${year}</ptt:YYYY>
          </ptt:GetOilPrice>
        </soap:Body>
      </soap:Envelope>
  ''';
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/soap+xml; charset=utf-8',
          'SOAPAction': 'http://www.pttor.com/GetOilPrice',
        },
        body: soapRequest,
      );

      if (response.statusCode == 200) {
        var document = xml.XmlDocument.parse(response.body);
        var resultElement =
            document.findAllElements('GetOilPriceResult').single;

        var fuelList =
            xml.XmlDocument.parse(resultElement.text).findAllElements('FUEL');
        List<Map<String, String>> fuelData = [];

        for (var fuel in fuelList) {
          var priceDate = fuel.findElements('PRICE_DATE').single.text;
          var product = fuel.findElements('PRODUCT').single.text;
          var price = fuel.findElements('PRICE').single.text;

          fuelData.add({
            'Product': product,
            'Price': price,
          });
        }

        // print(fuelData);
        return fuelData;
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    return [];
  }

  Future<List<dynamic>> getSuggestions() async {
    var now = DateTime.now();
    var date = now.day.toString();
    var month = now.month.toString();
    var year = now.year.toString();
    var oil = await OilService()._fetchOil(date, month, year);
    var oilname = oil.map((e) => e['Product']).toList();
    return oilname;
  }
}

// void main(List<String> args)async {
//   var oil = await OilService().getSuggestions();
//   print(oil);
// }
