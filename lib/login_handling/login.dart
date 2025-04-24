import 'package:flutter/material.dart';
import 'package:abis2/api_handling/api.dart';
import 'package:abis2/api_handling/BranchAPI.dart';
import 'package:connectivity_plus/connectivity_plus.dart';



String loginBearerToken = "";
String loginBranchId = "";
String loginBranchName = "";
String loginUserID = "";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;


  final bool _locationSelected = false;
  final bool _branchSelected = false;


  @override
  void dispose() {
    // Dispose controllers to free resources
    userIdController.dispose();
    passwordController.dispose();
    _checkInternetConnection();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Not connected
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet'),
          content: const Text('Please connect to the internet to continue.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _checkInternetConnection(); // Recheck
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // First Image spanning from below the AppBar to half of the screen
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity, // Full width
                child: Image.asset(
                  'Image/1.png', // Replace with your actual image path
                  fit: BoxFit.cover, // Adjust image to fill the space
                ),
              ),

              // Second Image below the first image
              Center(
                child: SizedBox(
                  height: 100, // Height equivalent to approximately two rows
                  width: 379.0, // Set a custom width to control the image size
                  child: Image.asset(
                    'Image/2.png', // Replace with your actual image path
                    fit: BoxFit.cover, // Adjust image scaling
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Text Fields
                    TextField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Your ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ), //input decore
                    ),

                    const SizedBox(height: 20),

                    // Row with 'Remember Me' checkbox and 'Forgot Password?' text button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me checkbox on the left
                        Row(
                          children: [
                            Checkbox(
                              value:
                                  false, // Change this value as per the state
                              onChanged: (bool? value) {
                                // Handle the change here
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),

                        // Forgot Password button on the right (transparent)
                        TextButton(
                          onPressed: () {
                            // Handle the press event here
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black, // Text color
                            backgroundColor:
                                Colors.transparent, // Transparent background
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        String userId = userIdController.text.trim();
                        String password = passwordController.text.trim();

                        if (userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('User ID is required.')),
                          );
                          return;
                        }

                        // Call the API for login
                        final response =
                            await ApiService.loginUser(userId, password);

                        if (response['success'] == true) {
                          String token = response['token'];
                          var user = response['user'];

                          setState(() {
                            loginBearerToken = token;
                            loginUserID = userIdController.text.trim();
                          });

                          // Fetch branches after successful login
                          try {
                            List<Branch> branches =
                                await BranchAPI.fetchBranches(
                                    userId, loginBearerToken);

                            if (mounted) {
                              _showBranchDialog(context, branches);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error fetching branches: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ??
                                  'Login failed! Please try again.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Set radius to 10
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors
                            .transparent, // To avoid shadow overlapping with the Ink
                      ),
                      child: Container(
                        width: 600,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10), // Rounded corners with 10 radius
                          color: const Color.fromARGB(
                              255, 7, 45, 101), // Navy blue color
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBranchDialog(BuildContext context, List<Branch> branchList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Your Branch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: branchList.map((branch) {
              return Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 5), // Add spacing between buttons
                child: ElevatedButton(
                  onPressed: () {
                    if (!mounted) return; // Ensure widget is still mounted

                    setState(() {
                      loginBranchName =
                          branch.Branchname; // Store the branch name
                      loginBranchId =
                          branch.Branchid; // Store the branch ID
                    });

                    Navigator.pop(context); // Close the branch dialog

                    // Navigate to the main page and pass branch details
                    _navigateToMainPage(
                        context, branch.Branchid, branch.Branchname);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set button color
                    minimumSize: const Size(150, 50), // Set width and height
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Set border radius
                    ),
                  ),
                  child: Text(
                    '${branch.Branchid}, ${branch.Branchname}',
                    style:
                        const TextStyle(color: Colors.white), // Set text color
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

// Navigate to the main page ('/') and pass branch details
  void _navigateToMainPage(
      BuildContext context, String branchId, String branchName) {
    Navigator.pushReplacementNamed(
      context,
      '/',
      arguments: {
        'BranchId': branchId,
        'BranchName': branchName,
      },
    );
  }

// Call this method when you receive the branch data response
  void showBranchSelection(
      BuildContext context, List<Map<String, dynamic>> responseData) {
    List<Branch> branchList =
        responseData.map((data) => Branch.fromJson(data)).toList();
    _showBranchDialog(context, branchList);
  }
}

class Branch {
  final String Branchid;
  final String Branchname;

  Branch({required this.Branchid, required this.Branchname});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      Branchid: json['BranchId'],
      Branchname: json['BranchName'],
    );
  }
}
