using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class OpenningBook : MonoBehaviour
{
    public GameObject join;
    public GameObject cub;
    bool on;
   public void OpenBook( )
    {
        //LeanTween.rotateX(join, -180, 2);
        //LeanTween.rotateLocal(join, Vector3.zero, 2);
        LeanTween.rotateAround(join, new Vector3(1, 0, 0), -180, 2);
    }

    private void Update()
    {
        if(Vector3.Angle(Vector3.forward, join.transform.forward) <=90)
        join.transform.LookAt(new Vector3(this.transform.position.x, cub.transform.position.y, cub.transform.position.z)) ;
        else join.transform.LookAt(new Vector3(this.transform.position.x, cub.transform.position.y, cub.transform.position.z) , Vector3.down);
    }



}
