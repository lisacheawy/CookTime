import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Components/Header.dart';
import '../../Utils/CustomDialogUtils.dart';
import '../../Utils/FetchRecipeUtils.dart';
import '../../constants.dart';
import '../RecipeResult/RecipeResultScreen.dart';

class KeyboardInputScreen extends StatefulWidget {
  const KeyboardInputScreen({Key? key}) : super(key: key);

  @override
  State<KeyboardInputScreen> createState() => _KeyboardInputScreenState();
}

class _KeyboardInputScreenState extends State<KeyboardInputScreen> {
  final _auth = FirebaseAuth.instance;
  final ScrollController sController = ScrollController();
  List<TextEditingController> controllers = [];
  List<String> ingredientList = [];
  int counter = 1;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }

  void checkFields() {
    for (var i = 0; i < controllers.length; i++) {
      //remove empty field when unfocused
      if (counter > 1 && controllers[i].text == "" && mounted) {
        setState(() {
          controllers.removeAt(i);
          counter--;
        });
      }
    }
  }

  void getTextIngredients() {
    List<String> tempList = [];
    for (var i = 0; i < controllers.length; i++) {
      if (controllers[i].text != "") {
        tempList.add(controllers[i].text);
      }
    }
    if (mounted) {
      setState(() {
        ingredientList = tempList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              checkFields();
            },
            child: Body(context)),
        floatingActionButton: Container(
          margin: EdgeInsets.only(
              left: kDisplayWidth(context) * 0.12,
              right: kDisplayWidth(context) * 0.035),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () {
                    if (controllers.last.text != "" && mounted) {
                      setState(() {
                        counter++;
                        controllers.add(TextEditingController());
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: kDefaultPadding * 0.65,
                    ),
                    height: kDisplayWidth(context) * 0.17,
                    width: kDisplayWidth(context) * 0.17,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: kWhite,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 3),
                              blurRadius: 6)
                        ]),
                    child: SvgPicture.asset('assets/icons/add.svg'),
                  )),
              Spacer(),
              GestureDetector(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    getTextIngredients();
                    if (ingredientList.isEmpty) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) => AlertDialog(
                                content: Container(
                                  padding:
                                      EdgeInsets.all(kDefaultPadding * 0.3),
                                  child: Text(
                                    'Please input at least one ingredient.',
                                    textScaleFactor: 1.0,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK',
                                          textScaleFactor: 1.0,
                                          style:
                                              TextStyle(color: kPrimaryColor)))
                                ],
                              ));
                    } else {
                      showCustomDialog(
                          context, "loading", "Searching for recipes");
                      var recipes = await getRecipes(_auth.currentUser!.uid,
                          ingredientList, context, mounted);
                      if (recipes.isNotEmpty && mounted) {
                        Navigator.of(context).pop(); //remove dialog box
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RecipeResultScreen(
                                results: recipes,
                                header: "Recipe Results",
                                returnText: "Return to ingredients",
                                backPressed: () async {
                                  return true;
                                },
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            // RecipeResultScreen(),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: kDisplayWidth(context) * 0.04),
                    height: kDisplayHeight(context) * 0.07,
                    width: kDisplayWidth(context) * 0.53,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: kPrimaryColor,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 3),
                              blurRadius: 6)
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Search for Recipes',
                            textScaleFactor: 1.0,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.w500)),
                        Icon(
                          CupertinoIcons.right_chevron,
                          color: kTextColor,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }

  SizedBox Body(BuildContext context) {
    return SizedBox(
      height: kDisplayHeight(context),
      child: Column(
        children: [
          Header(
            title: "Keyboard Input",
            padding: EdgeInsets.only(
                top: kToolbarHeight * 1.3, bottom: kToolbarHeight * 0.15),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            text: 'Cancel',
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: CupertinoScrollbar(
                thickness: 5,
                thumbVisibility: true,
                controller: sController,
                child: Container(
                  height: kDisplayHeight_WoTool(context),
                  margin: EdgeInsets.symmetric(
                      horizontal: kDisplayWidth(context) * 0.07),
                  child: ListView.builder(
                      controller: sController,
                      itemCount: counter + 2,
                      itemBuilder: (ctx, index) {
                        return (controllers.asMap().containsKey(index))
                            ? SizedBox(
                                width: kDisplayWidth(context),
                                height: kDisplayHeight_WoTool(context) * 0.07,
                                child: LayoutBuilder(builder:
                                    (BuildContext context,
                                        BoxConstraints constraints) {
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth * 0.8,
                                        child: TextField(
                                          maxLength: 30,
                                          //only allow text
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[a-zA-Z ]")),
                                          ],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: kSecondaryColor)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: kPrimaryColor)),
                                          ),
                                          controller: controllers[index],
                                          autofocus: true,
                                          onSubmitted: (_) {
                                            if (mounted) {
                                              //only allow new text field if current field is not empty and it is the last in the list
                                              if (controllers[index].text !=
                                                      "" &&
                                                  index ==
                                                      controllers.length - 1) {
                                                setState(() {
                                                  counter++;
                                                  controllers.add(
                                                      TextEditingController());
                                                });
                                              }
                                              //remove field if it is empty
                                              else if (controllers[index]
                                                          .text ==
                                                      "" &&
                                                  counter > 1) {
                                                setState(() {
                                                  counter--;
                                                  controllers.removeAt(index);
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (mounted && counter > 1) {
                                            setState(() {
                                              counter--;
                                              controllers.removeAt(index);
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: constraints.maxWidth * 0.2,
                                          height: constraints.maxHeight * 0.5,
                                          padding: EdgeInsets.only(
                                              right: kDisplayWidth(context) *
                                                  0.02),
                                          child: SvgPicture.asset(
                                              fit: BoxFit.fitHeight,
                                              alignment: Alignment.centerRight,
                                              'assets/icons/garbage-can.svg'),
                                        ),
                                      )
                                    ],
                                  );
                                }))
                            : SizedBox(
                                width: kDisplayWidth(context),
                                height: kDisplayHeight_WoTool(context) * 0.07,
                              );
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
