import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_cubit.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_cubit.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_state.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().loadUserProfile(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: state.user.profileImageUrl != null
                              ? NetworkImage(state.user.profileImageUrl!)
                              : null,
                          child: state.user.profileImageUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          state.user.fullName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.user.email,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),

                              TextButton(
                                onPressed: () {
                                  context.read<AuthCubit>().signOut();
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
