import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/big_icon_button.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProjectPage extends StatefulWidget {
  final bool goStraightToTool;
  final bool withoutRealProject;
  final ProjectBlock? toolToOpenDirectly;
  final bool pianoAlreadyOn;

  const ProjectPage(
      {super.key,
      required this.goStraightToTool,
      this.toolToOpenDirectly,
      required this.withoutRealProject,
      this.pianoAlreadyOn = false});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late bool _showBlocks;

  late Project _project;
  bool _withoutProject = false;

  final TextEditingController _titleController = TextEditingController();

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyChangeTitle = GlobalKey();

  @override
  void initState() {
    super.initState();

    _withoutProject = widget.withoutRealProject;

    _project = Provider.of<Project>(context, listen: false);

    _titleController.text = _project.title;

    if (_project.blocks.isEmpty) {
      _showBlocks = false;
    } else {
      _showBlocks = true;
    }

    _project.timeLastModified = getCurrentDateTime();

    if (widget.goStraightToTool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToTool(context, _project, widget.toolToOpenDirectly!, pianoAleadyOn: widget.pianoAlreadyOn)
            .then((_) => setState(() {}));
      });
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    if (context.read<ProjectLibrary>().showProjectPageTutorial && !widget.goStraightToTool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createWalkthrough();
        _walkthrough.show(context);
      });
    }
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyChangeTitle,
        "Tap here to edit the title of your project",
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _walkthrough.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showProjectPageTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
      },
      context,
    );
  }

  Future<bool?> _deleteBlock({bool deleteAll = false}) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete?", style: TextStyle(color: ColorTheme.primary)),
          content: deleteAll
              ? const Text("Do you really want to delete all tools in this project?",
                  style: TextStyle(color: ColorTheme.primary))
              : const Text("Do you really want to delete this tool?", style: TextStyle(color: ColorTheme.primary)),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No")),
            TIOFlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: "Yes",
              boldText: true,
            ),
          ],
        ),
      );

  void _createBlockAndGoToTool(BlockTypeInfo info, String blockTitle) {
    if (_withoutProject) {
      final projectLibrary = context.read<ProjectLibrary>();
      projectLibrary.addProject(_project);
      _withoutProject = false;
    }

    final newBlock = info.createWithTitle(blockTitle);

    _project.addBlock(newBlock);
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

    setState(() {
      _showBlocks = true;
    });

    goToTool(context, _project, newBlock).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (_showBlocks) {
      return _buildProjectPage(context);
    } else {
      return _buildChooseToolPage();
    }
  }

  Widget _buildProjectPage(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            final newTitle = await showEditTextDialog(
              context: context,
              label: TIOMusicParams.projectTitle,
              value: _project.title,
            );
            if (newTitle == null) return;
            _project.title = newTitle;
            if (context.mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
            setState(() {});
          },
          child: Text(
            _project.title,
            style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
          ),
        ),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        actions: [
          IconButton(
              onPressed: () async {
                bool? deleteBlock = await _deleteBlock(deleteAll: true);
                if (deleteBlock != null && deleteBlock) {
                  if (context.mounted) {
                    _project.clearBlocks(context.read<ProjectLibrary>());
                    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                    setState(() {});
                  }
                }
              },
              icon: const Icon(Icons.delete_outlined)),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              "assets/images/tiomusic-bg.png",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: TIOMusicParams.bigSpaceAboveList),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _project.blocks.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index >= _project.blocks.length) {
                  return const SizedBox(height: 120);
                } else {
                  return CardListTile(
                    title: _project.blocks[index].title,
                    subtitle: formatSettingValues(_project.blocks[index].getSettingsFormatted()),
                    leadingPicture: circleToolIcon(_project.blocks[index].icon),
                    trailingIcon: IconButton(
                      onPressed: () =>
                          {goToTool(context, _project, _project.blocks[index]).then((_) => setState(() {}))},
                      icon: const Icon(Icons.arrow_forward),
                      color: ColorTheme.primaryFixedDim,
                    ),
                    menuIconOne: IconButton(
                      onPressed: () async {
                        bool? deleteBlock = await _deleteBlock();
                        if (deleteBlock != null && deleteBlock) {
                          if (context.mounted) {
                            _project.removeBlock(_project.blocks[index], context.read<ProjectLibrary>());
                            FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                          }
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.delete_outlined),
                      color: ColorTheme.surfaceTint,
                    ),
                    onTapFunction: () {
                      goToTool(context, _project, _project.blocks[index]).then((_) => setState(() {}));
                    },
                  );
                }
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // button to add a new tool
              BigIconButton(
                icon: Icons.add,
                onPressed: () {
                  setState(() {
                    _showBlocks = false;
                  });
                },
              ),
              const SizedBox(
                height: TIOMusicParams.spaceBetweenPlusButtonAndBottom,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChooseToolPage() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Choose Type of Tool"),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(
          onPressed: () {
            if (_project.blocks.isEmpty) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _showBlocks = true;
              });
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              "assets/images/tiomusic-bg.png",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: TIOMusicParams.bigSpaceAboveList),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BlockType.values.length,
              itemBuilder: (BuildContext context, int index) {
                var info = blockTypeInfos[BlockType.values[index]]!;
                return CardListTile(
                  title: info.name,
                  subtitle: info.description,
                  trailingIcon: IconButton(
                    onPressed: () {
                      _onNewToolTilePressed(info);
                    },
                    icon: const Icon(Icons.add),
                    color: ColorTheme.surfaceTint,
                  ),
                  leadingPicture: circleToolIcon(info.icon),
                  onTapFunction: () {
                    _onNewToolTilePressed(info);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onNewToolTilePressed(BlockTypeInfo info) async {
    final newTitle = await showEditTextDialog(
      context: context,
      label: TIOMusicParams.toolTitle,
      value: "${info.name} ${_project.toolCounter[info.kind]! + 1}",
      isNew: true,
    );
    if (newTitle == null) return;

    _project.increaseCounter(info.kind);
    if (mounted) {
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    _createBlockAndGoToTool(info, newTitle);
  }
}
