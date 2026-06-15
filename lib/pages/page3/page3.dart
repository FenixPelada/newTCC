import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Página 3",
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                headingRowColor: WidgetStateProperty.all(
                  Colors.blue.shade100,
                ),
                columns: const [
                  DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cargo', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('Ana')),
                    DataCell(Text('ana@email.com')),
                    DataCell(Text('Dev')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('João')),
                    DataCell(Text('joao@email.com')),
                    DataCell(Text('Designer')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Maria')),
                    DataCell(Text('maria@email.com')),
                    DataCell(Text('Designer')),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}