import 'package:flutter/material.dart';
import 'package:trung_son/constants.dart';
import 'package:trung_son/helper/productHelper.dart';
import 'package:trung_son/models/product/items.dart';
import 'package:trung_son/models/product/product.dart';
import 'package:trung_son/screens/home/components/Notifier.dart';
import 'package:trung_son/screens/home/components/item_card.dart';

class Body extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BodyPage(),
    );
  }
}

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  Future<Product> futureProduct;
  int currentPage = 1;
  int pageSize = 5;
  List<Items> originalItems = [];
  List<Items> items = [];

  Notifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = Notifier();
    notifier.getMore();
    futureProduct = getProducts(
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Items>>(
        valueListenable: notifier,
        builder: (BuildContext context, List<Items> value, Widget child) {
          return value == null
              ? Center(child: Text("Loading ..."))
              : RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async {
                    return await notifier.reload();
                  },
                  child: value.isEmpty
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return const Center(child: Text('No Item!'));
                          })
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollEndNotification &&
                                scrollInfo.metrics.extentAfter == 0) {
                              notifier.getMore();
                              return true;
                            }
                            return false;
                          },
                          child: ListView.separated(
                              separatorBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Divider(),
                                  ),
                              padding: EdgeInsets.only(top: 20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: value.length,
                              cacheExtent: 5,
                              itemBuilder: (BuildContext context, int index) {
                                Items item = value[index];
                                final file = item.mediaGalleryEntries[0].file;
                                final imgPath =
                                    'https://trungson.inapps.technology/media/catalog/product/$file';
                                return Column(
                                  children: [
                                    ItemProduct(
                                      title: item.name,
                                      imgPath: imgPath,
                                      price: item.price,
                                      isFavorite: false,
                                    ),
                                    index == value.length - 1
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              backgroundColor: kPrimaryColor,
                                            ),
                                          )
                                        : Container(),
                                  ],
                                );
                              }),
                        ),
                );
        });
  }

//  child: FutureBuilder<Product>(
//  future: futureProduct,
//  builder: (context, snapshot) {
//  if (snapshot.hasData) {
//  final List<Items> items = snapshot.data.items;
//  originalItems.addAll(items);
//  return buildProducts(items: originalItems);
//  } else if (snapshot.hasError) {
//  print(snapshot.error);
//  return Text("${snapshot.error}");
//  }
//  return CircularProgressIndicator();
//  },
//  ),

  ListView buildProducts({List<Items> items}) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        Items item = items[index];

        final file = item.mediaGalleryEntries[0].file;
        final imgPath =
            'https://trungson.inapps.technology/media/catalog/product/$file';
        return ItemProduct(
          title: item.name,
          imgPath: imgPath,
          price: item.price,
        );
      },
    );
  }
}
