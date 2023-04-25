import os

def create_sidebar(parent, sidebar, level=0):
    for item in sorted(os.listdir(parent)):
        path = os.path.join(parent, item)
        if os.path.isdir(path):
            if level == 0:
                sidebar.write(f'▪ {item.upper()}\n\n')
            else:
                sidebar.write(f'{level * " "} - {item}\n\n')
            create_sidebar(path, sidebar, level + 1)
        elif item.endswith('.md') and item != '_Sidebar.md':
            sidebar.write(f'{level * " "} - [{item[:-3]}]({parent.replace("wiki/", "")}/{item})\n')

parent = 'wiki'
with open(os.path.join(parent, '_Sidebar.md'), 'w') as sidebar:
    create_sidebar(parent, sidebar)

