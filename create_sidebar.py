import os

def create_sidebar(parent, sidebar, level=0):
    indent = '  ' * level

    for item in sorted(os.listdir(parent)):
        path = os.path.join(parent, item)
        if os.path.isdir(path):
            if level == 0:
                sidebar.write(f'\n{indent}**{item.upper()}**\n\n')
            else:
                sidebar.write(f'\n{indent}- {item}\n')
            create_sidebar(path, sidebar, level + 1)
        elif item.endswith('.md') and item != '_Sidebar.md':
            # Remove the ".md" extension from the links in the sidebar
            sidebar.write(f'{indent}- [{item[:-3]}]({parent.replace("wiki/", "")}/{item[:-3]})\n')

    if level == 0:
        sidebar.write('\n')

parent = 'wiki'
with open(os.path.join(parent, '_Sidebar.md'), 'w') as sidebar:
    create_sidebar(parent, sidebar)

