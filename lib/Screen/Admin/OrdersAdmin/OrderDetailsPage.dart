import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurantee/Bloc/Orders/orders_bloc.dart';
import 'package:restaurantee/Controller/OrdersController.dart';
import 'package:restaurantee/Helpers/Date.dart';
import 'package:restaurantee/Helpers/Helpers.dart';
import 'package:restaurantee/Models/Response/OrderDetailsResponse.dart';
import 'package:restaurantee/Models/Response/OrdersByStatusResponse.dart';
import 'package:restaurantee/Screen/Admin/OrdersAdmin/OrdersAdminPage.dart';
import 'package:restaurantee/Services/url.dart';
import 'package:restaurantee/Themes/ColorsFrave.dart';
import 'package:restaurantee/Widgets/AnimationRoute.dart';
import 'package:restaurantee/Widgets/Widgets.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrdersResponse order;

  const OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is LoadingOrderState) {
          modalLoading(context);
        } else if (state is SuccessOrdersState) {
          Navigator.pop(context);
          modalSuccess(
              context,
              'DISPATCHED',
              () => Navigator.pushReplacement(
                  context, routeFrave(page: OrdersAdminPage())));
        } else if (state is FailureOrdersState) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: TextFrave(text: state.error, color: Colors.white),
              backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextFrave(text: 'Order N° ${order.orderId}'),
          centerTitle: true,
          leadingWidth: 80,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 17, color: ColorsFrave.primaryColor),
                TextFrave(
                    text: 'Back', color: ColorsFrave.primaryColor, fontSize: 17)
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                flex: 2,
                child: FutureBuilder<List<DetailsOrder>?>(
                    future: ordersController
                        .gerOrderDetailsById(order.orderId.toString()),
                    builder: (context, snapshot) => (!snapshot.hasData)
                        ? Column(
                            children: const [
                              ShimmerFrave(),
                              SizedBox(height: 10.0),
                              ShimmerFrave(),
                              SizedBox(height: 10.0),
                              ShimmerFrave(),
                            ],
                          )
                        : _ListProductsDetails(
                            listProductDetails: snapshot.data!))),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextFrave(
                          text: 'Total',
                          color: ColorsFrave.secundaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                      TextFrave(
                          text: '\$ ${order.amount}0',
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextFrave(
                          text: 'Cliente:',
                          color: ColorsFrave.secundaryColor,
                          fontSize: 16),
                      TextFrave(text: '${order.cliente}'),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextFrave(
                          text: 'Date:',
                          color: ColorsFrave.secundaryColor,
                          fontSize: 16),
                      TextFrave(
                          text: DateFrave.getDateOrder(
                              order.currentDate.toString()),
                          fontSize: 16),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const TextFrave(
                      text: 'Address shipping:',
                      color: ColorsFrave.secundaryColor,
                      fontSize: 16),
                  const SizedBox(height: 5.0),
                  TextFrave(text: order.reference!, maxLine: 2, fontSize: 16),
                  const SizedBox(height: 5.0),
                  (order.status == 'DISPATCHED')
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TextFrave(
                                text: 'Delivery',
                                fontSize: 17,
                                color: ColorsFrave.secundaryColor),
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(URLS.BASE_URL +
                                              order.deliveryImage!))),
                                ),
                                const SizedBox(width: 10.0),
                                TextFrave(text: order.delivery!, fontSize: 17)
                              ],
                            )
                          ],
                        )
                      : const SizedBox()
                ],
              ),
            )),
            (order.status == 'PAID OUT')
                ? Container(
                    padding: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BtnFrave(
                          text: 'SELECT DELIVERY',
                          fontWeight: FontWeight.w500,
                          onPressed: () => modalSelectDelivery(
                              context, order.orderId.toString()),
                        )
                      ],
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class _ListProductsDetails extends StatelessWidget {
  final List<DetailsOrder> listProductDetails;

  const _ListProductsDetails({required this.listProductDetails});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: listProductDetails.length,
      separatorBuilder: (_, index) => Divider(),
      itemBuilder: (_, i) => Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          URLS.BASE_URL + listProductDetails[i].picture!))),
            ),
            const SizedBox(width: 15.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFrave(
                    text: listProductDetails[i].nameProduct!,
                    fontWeight: FontWeight.w500),
                const SizedBox(height: 5.0),
                TextFrave(
                    text: 'Quantity: ${listProductDetails[i].quantity}',
                    color: Colors.grey,
                    fontSize: 17),
              ],
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: TextFrave(text: '\$ ${listProductDetails[i].total}'),
            ))
          ],
        ),
      ),
    );
  }
}
