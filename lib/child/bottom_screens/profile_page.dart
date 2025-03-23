import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:title_proj/child/LoginScreen.dart';
import 'package:title_proj/utils/constants.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController childEmailC = TextEditingController();
  final TextEditingController guardianEmailC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  File? _profilePic;

  // Picking an image for profile
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePic = File(pickedFile.path);
      });
    }
  }

  // Sign out user
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      goTo(context, LoginScreen());
    } on FirebaseAuthException catch (e) {
      dialogueBox(context, e.toString());
    }
  }

  // Update profile details (Name, Email, Phone, Profile Pic)
  Future<void> _updateProfile() async {
    try {
      if (_profilePic != null) {
        // Upload the profile picture
        await uploadProfilePic();
      }
      // Update other profile fields (name, email, phone)
      await FirebaseAuth.instance.currentUser!.updateDisplayName(nameC.text);
      await FirebaseAuth.instance.currentUser!
          .updateEmail(childEmailC.text); // Or update phone here
      print("Profile updated successfully");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> uploadProfilePic() async {
    if (_profilePic != null) {
      try {
        // Upload the profile picture to Firebase Storage and update the profile
        final storageRef = FirebaseStorage.instance.ref().child(
            'profile_pics/${FirebaseAuth.instance.currentUser!.uid}.jpg');
        await storageRef.putFile(_profilePic!);
        String downloadURL = await storageRef.getDownloadURL();

        // Now update the user's profile with the download URL
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadURL);
        print("Profile updated with new picture: $downloadURL");
      } catch (e) {
        print("Error updating profile picture: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Page")),
      resizeToAvoidBottomInset:
          true, // Ensure the UI is resized when the keyboard is displayed
      body: SingleChildScrollView(
        // Make the body scrollable when the keyboard appears
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture section
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePic != null
                    ? FileImage(_profilePic!)
                    : AssetImage('assets/placeholder.png') as ImageProvider,
                child: _profilePic == null
                    ? Icon(Icons.camera_alt, color: Colors.pink)
                    : null,
              ),
            ),
            SizedBox(height: 20),

            // Name field
            TextFormField(
              controller: nameC,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),

            // Child Email field
            TextFormField(
              controller: childEmailC,
              decoration: InputDecoration(labelText: 'Child Email'),
            ),
            SizedBox(height: 10),

            // Parent Email field
            TextFormField(
              controller: guardianEmailC,
              decoration: InputDecoration(labelText: 'Parent Email'),
            ),
            SizedBox(height: 10),

            // Phone Number field
            TextFormField(
              controller: phoneC,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 25),

            // Update button
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, // ✅ Pink background
                foregroundColor: Colors.white, // ✅ White text
              ),
              child: const Text("UPDATE"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, // ✅ Pink background
                foregroundColor: Colors.white, // ✅ White text
              ),
              child: const Text("SIGN OUT"),
            ),
          ],
        ),
      ),
    );
  }
}
